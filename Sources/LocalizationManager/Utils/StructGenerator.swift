//
//  StructGeneration.swift
//  
//
//  Created by Alsu Faizova on 16.05.2024.
//

import Foundation

enum StructGeneration {

    // MARK: Public

    static func generateStruct() {
        guard let directory = Utils.projectDirectory else { return }
        let keys = Utils.getAllUniqueKeys()
        
        guard !keys.isEmpty else {
            print("No keys in the file")
            return
        }
        
        let structure = buildStructure(from: keys)
        var structContent = "struct Strings {\n"
        structContent += generateStructContent(from: structure)
        structContent += "}\n"

        let outputFilePath = directory + "/Strings.swift"

        // Проверяем, существует ли файл, и создаем его, если он не существует
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outputFilePath) {
            fileManager.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        }
        
        // Записываем содержимое в файл
        do {
            try structContent.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
            print("Generated Strings struct at: \(outputFilePath)".inGreen)
        } catch {
            print("Failed to write to file: \(error)".inRed)
        }

        createStringExtensionsFile()
    }

    // MARK: Private

    private static func buildStructure(from keys: [String]) -> [String: Any] {
        var structure = [String: Any]()

        for key in keys {
            let components = key.split(separator: "_")
            updateStructure(&structure, with: components, originalKey: key)
        }

        return structure
    }

    private static func updateStructure(_ structure: inout [String: Any], with components: [Substring], originalKey: String) {
        guard let firstComponent = components.first else { return }

        let componentString = String(firstComponent)
        if components.count == 1 {
            structure[componentString] = "static let \(componentString) = \"\(originalKey)\".localized()"
        } else {
            if structure[componentString] == nil {
                structure[componentString] = [String: Any]()
            }

            var nestedStructure = structure[componentString] as! [String: Any]
            updateStructure(&nestedStructure, with: Array(components.dropFirst()), originalKey: originalKey)
            structure[componentString] = nestedStructure
        }
    }

    private static func generateStructContent(from structure: [String: Any], indent: String = "    ") -> String {
        var singletonProperties = ""
        var nestedStruct = ""

        for (key, value) in structure {
            if let nested = value as? [String: Any] {
                nestedStruct += "\(indent)struct \(key.capitalized) {\n"
                nestedStruct += generateStructContent(from: nested, indent: indent + "    ")
                nestedStruct += "\(indent)}\n"
            } else if let property = value as? String {
                singletonProperties += "\(indent)\(property)\n"
            }
        }

        return singletonProperties + nestedStruct
    }

    private static func createStringExtensionsFile() {
        guard let directory = Utils.projectDirectory else { return }

        guard let extensionsContent = Converter.readJSONFile(at: "stringExtension.json") else { return }

        let outputFilePath = directory + "/String+Extensions.swift"

        // Проверяем, существует ли файл
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: outputFilePath) {
            // Если файл существует, проверяем его содержимое на наличие функции localized()
            guard let existingContent = try? String(contentsOfFile: outputFilePath) else {
                print("Failed to read existing file content.")
                return
            }
            if existingContent.contains("func localized() -> String {") { return }
        }

        do {
            try extensionsContent.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write to file: \(error)".inRed)
        }
    }
}
