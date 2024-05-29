//
//  CodeUpdater.swift
//
//
//  Created by Alsu Faizova on 25.05.2024.
//

import Foundation

struct CodeUpdater {
    static func replaceStringsWithStructuredVariables() {
        let projectFiles = FileService.getAllProjectFiles()

        for file in projectFiles {
            print(file)
            guard let fileContent = FileService.readFile(at: file) else { continue }
            
            var updatedContent = fileContent

            for line in fileContent.components(separatedBy: "\n") {
                if let stringLiteral = AST.getStringLiteral(from: line) {
                    if let key = KeyService.findKey(for: stringLiteral) {
                        let structuredVariable = KeyService.getStructuredVariable(for: key)
                        updatedContent = updatedContent.replacingOccurrences(of: "\"\(stringLiteral)\"", with: structuredVariable)
                    }
                }
            }

            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: file)
                let successfulWrite = Utils.writeToFile(content: updatedContent, to: file)
                if successfulWrite {
                    print("All string literals were successfully changed to existing keys from localized files".inGreen)
                } else {
                    print("Failed to write to file at path: \(file)".inRed)
                }
            } catch {
                print("Failed to remove or create file at path: \(file), error: \(error)".inRed)
            }
        }
    }
}
