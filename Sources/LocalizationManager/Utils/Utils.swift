//
//  Utils.swift
//  
//
//  Created by Alsu Faizova on 12.05.2024.
//

import Foundation

enum Utils {
    static var projectDirectory: String? {
        CommandLine.arguments.count <= 1 ? nil : CommandLine.arguments[1]
    }

    static var localizableFiles: [String] {
        guard let rootDir = projectDirectory,
              let files = FileManager.default.enumerator(atPath: rootDir)?.allObjects.compactMap({
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

    static func contentOf(file relativeFilePath: String) -> [String] {
        guard let rootDir = projectDirectory else { return [] }
        
        let filePath = "\(rootDir)/\(relativeFilePath)"
        guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return []
        }
        
        let trimmedContent = fileContent.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.isEmpty ? [] : trimmedContent.components(separatedBy: "\n")
    }

    static func createLocalizableFile(for language: String, in directory: String) {
        let filePath = "\(directory)/\(language).lproj/Localizable.strings"
        let fileManager = FileManager.default
        let fileDirectory = "\(directory)/\(language).lproj"
        
        do {
            try fileManager.createDirectory(atPath: fileDirectory, withIntermediateDirectories: true, attributes: nil)
            if !fileManager.fileExists(atPath: filePath) {
                fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
                print("Created \(language).lproj/Localizable.strings".inGreen)

                // Синхронизируем файл с остальными
                let _ = Synchronization.synchronizeFile(at: "\(language).lproj/Localizable.strings")
            } else {
                print("\(language.uppercased()) language already exists".inRed)
            }
        } catch {
            print("Failed to create file \(filePath): \(error)".inRed)
        }
    }

    static func write(content: String, to relativeFilePath: String) -> Bool {
        guard let rootDir = projectDirectory else { return false }
        let filePath = "file:///\(rootDir)/\(relativeFilePath)"

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
}
