//
//  Utils.swift
//  
//
//  Created by Alsu Faizova on 12.05.2024.
//

import Foundation

enum Utils {

    // MARK: Public

    static var projectDirectory: String? {
        CommandLine.arguments.count <= 1 ? nil : CommandLine.arguments[1]
    }

    static var resourceDirectory: String? {
        guard let projectDirectory else { return nil }
        return "\(projectDirectory)/Resources"
    }

    static var localizableFiles: [String] {
        guard let dir = resourceDirectory,
              let files = FileManager.default.enumerator(atPath: dir)?.allObjects.compactMap({
                  $0 as? String
              })
        else { return [] }

        return files.filter({$0.hasSuffix("/Localizable.strings") })
    }

    static func languageFromFilePath(_ filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        if let languageComponent = components.first, languageComponent.contains(".lproj") {
            return String(languageComponent.dropLast(6)) // Убираем ".lproj"
        }
        return filePath // Возвращаем весь путь, если не удалось извлечь язык
    }
    
    static func contentOf(file relativeFilePath: String) -> FileContent {
        guard let resourceDirectory else { return [] }

        let filePath = "\(resourceDirectory)/\(relativeFilePath)"
        guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return []
        }
        
        let trimmedContent = fileContent.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.isEmpty ? [] : trimmedContent.components(separatedBy: "\n")
    }

    static func createLocalizableFile(for language: String) {
        guard let resourceDirectory else { return }

        let fileManager = FileManager.default
        let fileDirectory = "\(resourceDirectory)/\(language).lproj"
        let filePath = "\(fileDirectory)/Localizable.strings"
        
        do {
            // Создаем папку Resources, если она не существует
            try fileManager.createDirectory(atPath: resourceDirectory, withIntermediateDirectories: true, attributes: nil)
            
            // Создаем папку для языка, если она не существует
            try fileManager.createDirectory(atPath: fileDirectory, withIntermediateDirectories: true, attributes: nil)
            
            // Создаем файл локализации, если он не существует
            if !fileManager.fileExists(atPath: filePath) {
                fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
                print("Created \(language).lproj/Localizable.strings".inGreen)

                //Добавляем в файлы проекта
                XcodeProjectManager.addFileToProject(filePath: filePath)

                // Синхронизируем файл с остальными
                let _ = Synchronization.synchronizeFile(at: filePath)
            } else {
                print("\(language.uppercased()) language already exists".inRed)
            }
        } catch {
            print("Failed to create file \(filePath): \(error)".inRed)
        }
    }


    static func write(content: String, to relativeFilePath: String) -> Bool {
        guard let resourceDirectory else { return false }
        let filePath = "file:///\(resourceDirectory)/\(relativeFilePath)"

        guard let url = URL(string: filePath) else { return false }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    static func extractKeys(from fileContent: FileContent) -> [String] {
        var keys: [String] = []

        for line in fileContent {
            let key = extractKey(from: line)
            keys.append(key)
        }

        return keys
    }

    static func getAllUniqueKeys() -> [String] {
        guard let directory = Utils.resourceDirectory else { return [] }
        let fileManager = FileManager.default
        var allKeys = Set<String>()
        let enumerator = fileManager.enumerator(atPath: directory)
        
        while let filePath = enumerator?.nextObject() as? String {
            if filePath.hasSuffix(".strings") {
                let fullPath = (directory as NSString).appendingPathComponent(filePath)
                let content = contentOf(file: fullPath)
                let keys = extractKeys(from: content)
                allKeys.formUnion(keys)
            }
        }

        return Array(allKeys)
    }

    static func writeToFile(content: String, to filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Failed to write to file at path: \(filePath), error: \(error)".inRed)
            return false
        }
    }

    static func addKey(key: String, value: String, to relativeFilePath: String) {
        var fileContent = Utils.contentOf(file: relativeFilePath)

        // Проверка на существование ключа
        guard !fileContent.contains(where: { $0.contains("\"\(key)\"") }) else {
            print("Key \(key) already has value at \(relativeFilePath)".inRed)
            return
        }

        let newKeyValue = "\(key.quoted) = \(value.quoted);"
        fileContent.append(newKeyValue)

        // Сортировка контента по алфавиту
        fileContent.sort { line1, line2 in
            let key1 = extractKey(from: line1)
            let key2 = extractKey(from: line2)
            return key1 < key2
        }

        let updatedFileContent = fileContent.joined(separator: "\n")
        let successfulWrite = Utils.write(content: updatedFileContent, to: relativeFilePath)
        if successfulWrite {
            let lang = languageFromFilePath(relativeFilePath)
            print("Successfully added Key \(key) at \(lang.uppercased()) language".inGreen)
        }
    }

    // MARK: Private

    private static func extractKey(from line: String) -> String {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        guard !trimmedLine.isEmpty,
              !trimmedLine.hasPrefix("//"),
              !trimmedLine.hasPrefix("/*")
        else { return "" }
        
        if let range = trimmedLine.range(of: #"\"(.*?)\""#, options: .regularExpression) {
            let key = String(trimmedLine[range]).trimmingCharacters(in: .punctuationCharacters)
            return key
        }
        
        return ""
    }
}
