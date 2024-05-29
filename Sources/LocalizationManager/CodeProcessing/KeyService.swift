//
//  KeyService.swift
//
//
//  Created by Alsu Faizova on 25.05.2024.
//

import Foundation

struct KeyService {
    static func findKey(for stringLiteral: String) -> String? {
        let localizationFiles = FileService.getAllLocalizationFiles()
        
        for filePath in localizationFiles {
            if let key = findKey(in: filePath, for: stringLiteral) {
                return key
            }
        }
        
        return nil
    }

    // Функция преобразует ключ "main_top_label" в переменную "Strings.Main.Top.label"
    static func getStructuredVariable(for key: String) -> String {
        let components = key.split(separator: "_")
        
        let camelCaseComponents = components.map { component in
            return component.prefix(1).uppercased() + component.dropFirst()
        }
        
        if camelCaseComponents.isEmpty { return key }
        var structuredVariable = camelCaseComponents[0].lowercased()
        
        for component in camelCaseComponents.dropFirst() {
            structuredVariable += component
        }
        
        let pathComponents = ["Strings"] + camelCaseComponents.dropLast()
        let variableName = camelCaseComponents.last?.lowercased() ?? key

        let structuredPath = pathComponents.joined(separator: ".")
        
        return "\(structuredPath).\(variableName)"
    }

    private static func findKey(in filePath: String, for stringLiteral: String) -> String? {
        guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("Unable to read file at \(filePath)")
            return nil
        }

        let lines = fileContent.split(separator: "\n")

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
}
