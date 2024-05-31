//
//  FileService.swift
//
//
//  Created by Alsu Faizova on 25.05.2024.
//

import Foundation

enum FileService {

    // MARK: Public

    static func getAllProjectFiles() -> [String] {
        let fileManager = FileManager.default
        guard let projectDirectory = Utils.projectDirectory else { return [] }
        let rootURL = URL(fileURLWithPath: projectDirectory)
        var swiftFiles = [String]()

        let excludedFilesJSONName = "excluded_files.json"
        
        var excludedFiles = [String]()
        if let jsonString = Converter.readJSONFile(at: excludedFilesJSONName) {
            excludedFiles = jsonString.components(separatedBy: "\n").filter { !$0.isEmpty }
        }

        do {
            let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
            let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles, .skipsPackageDescendants])!

            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                
                if resourceValues.isDirectory == true {
                    if fileURL.lastPathComponent == "Resources" {
                        enumerator.skipDescendants()
                    }
                } else {
                    if fileURL.pathExtension == "swift" {
                        // Исключаем файлы, упомянутые в excludedFiles
                        if !excludedFiles.contains(fileURL.lastPathComponent) {
                            swiftFiles.append(fileURL.path)
                        }
                    }
                }
            }
        } catch {
            print("Failed to enumerate files in directory \(projectDirectory): \(error.localizedDescription)")
        }

        return swiftFiles
    }

    static func readFile(at filePath: String) -> String? {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: filePath) else {
            print("File does not exist at path: \(filePath)")
            return nil
        }
        
        do {
            let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
            return fileContent
        } catch {
            print("Failed to read file at path: \(filePath) with error: \(error)")
            return nil
        }
    }

    static func getAllLocalizationFiles() -> [String] {
        var localizationFiles: [String] = []
        let fileManager = FileManager.default
        guard let resourcePath = Utils.resourceDirectory else { return [] }
        
        if let enumerator = fileManager.enumerator(atPath: resourcePath) {
            for case let file as String in enumerator {
                if file.hasSuffix("Localizable.strings") {
                    localizationFiles.append("\(resourcePath)/\(file)")
                }
            }
        }
        
        return localizationFiles
    }

    static func setReadWritePermissions(for directory: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/chmod")
        process.arguments = ["-R", "u+rw,g+rw,o+rw", directory]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return
        }
    }
    
    // MARK: Private

    private func findKey(in filePath: String, for stringLiteral: String) -> String? {
        guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("Unable to read file at \(filePath)")
            return nil
        }

        let lines = fileContent.split(separator: "\n")

        // Ищем строку, содержащую stringLiteral
        for line in lines {
            if line.contains("\"\(stringLiteral)\"") {
                if let range = line.range(of: #"\"(.*?)\" = \"\#(stringLiteral)\";"#, options: .regularExpression) {
                    let keyValuePair = line[range]
                    if let keyRange = keyValuePair.range(of: #"^\"(.*?)\""#, options: .regularExpression) {
                        let key = String(keyValuePair[keyRange])
                            .trimmingCharacters(in: .punctuationCharacters)
                        return key
                    }
                }
            }
        }

        return nil
    }

    private static func isInExcludedDirectories(_ filePath: String, _ excludedDirectories: [String]) -> Bool {
        for directory in excludedDirectories {
            if filePath.hasPrefix(directory + "/") {
                return true
            }
        }
        return false
    }
}
