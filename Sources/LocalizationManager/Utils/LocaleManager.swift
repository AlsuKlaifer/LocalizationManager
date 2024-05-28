//
//  LocaleManager.swift
//  
//
//  Created by Alsu Faizova on 12.05.2024.
//

import Foundation

enum LocaleManager {
    static func tryAddingKey() {
        print("What key do you want to add?".inYellow)
        
        guard let key = readLine(), !key.isEmpty else {
            print("Invalid Key".inRed)
            return
        }
        
        var filesWithValues: [String: String] = [:]
        
        for relativeFilePath in Utils.localizableFiles {
            let language = Utils.languageFromFilePath(relativeFilePath)
            print("Enter value for \(language.uppercased())".inYellow)
            
            guard let value = readLine(), !value.isEmpty else {
                print("Invalid Value".inRed)
                return
            }
            filesWithValues[relativeFilePath] = value
        }
        
        for (relativeFilePath, value) in filesWithValues {
            Utils.addKey(key: key, value: value, to: relativeFilePath)
        }
    }

    static func tryModifyingKey() {
        print("What key do you want to Modify it's value?".inYellow)
        guard let key = readLine(), !key.isEmpty else {
            print("Invalid Key".inRed)
            return
        }
        var filesWithValues: [String: String] = [:]

        for relativeFilePath in Utils.localizableFiles {
            let language = Utils.languageFromFilePath(relativeFilePath)
            print("Enter value for \(language.uppercased())".inYellow)

            guard let value = readLine(), !value.isEmpty else {
                print("Invalid Value".inRed)
                continue
            }
            filesWithValues[relativeFilePath] = value
        }

        for (relativeFilePath, value) in filesWithValues {
            var fileContent = Utils.contentOf(file: relativeFilePath)
            guard fileContent.contains(key: key) else {
                print("Key \(key) doesn't have value at \(relativeFilePath)".inRed)
                continue
            }

            let index = fileContent.firstIndex(where: { $0.contains(key.quoted) })

            let newKeyValue = "\(key.quoted) = \(value.quoted);"
            if let index {
                fileContent[index] = newKeyValue
            } else {
                fileContent.append(newKeyValue)
            }

            let updatedFileContent = fileContent.joined(separator: "\n")
            let successfulWrite = Utils.write(content: updatedFileContent, to: relativeFilePath)
            if successfulWrite {
                print("Successfully modified value for Key \(key) at \(relativeFilePath)".inGreen)
            }
        }
    }

    static func tryRemovingKey() {
        print("What key do you want to remove?".inYellow)

        guard let key = readLine(), !key.isEmpty else {
            print("Invalid Key".inRed)
            return
        }

        for relativeFilePath in Utils.localizableFiles {
            var fileContent = Utils.contentOf(file: relativeFilePath)
            guard fileContent.contains(key: key) else {
                print("Key \(key) not found at \(relativeFilePath)".inRed)
                continue
            }
            fileContent.removeAll(where: { $0.contains(key.quoted) })

            let updatedFileContent = fileContent.joined(separator: "\n")
            let successfulWrite = Utils.write(content: updatedFileContent, to: relativeFilePath)
            if successfulWrite {
                print("Successfully deleted Key \(key) at \(relativeFilePath)".inGreen)
            }
        }
    }

    static func printKeys() {
        print("Enter the language code (e.g. EN/RU):".inYellow)
        
        guard let languageCode = readLine(), !languageCode.isEmpty else {
            print("Invalid language code".inRed)
            return
        }
        
        let localizableFile = Utils.localizableFiles.first { $0.contains("\(languageCode.lowercased()).lproj") }
        
        guard let file = localizableFile else {
            print("Localizable file for language \(languageCode.uppercased()) not found".inRed)
            return
        }
        
        let content = Utils.contentOf(file: file)
            
        guard !content.isEmpty else {
            print("No keys found in the file".inRed)
            return
        }
        
        let keys = Utils.extractKeys(from: content)
        
        guard !keys.isEmpty else {
            print("No keys found in the file".inRed)
            return
        }
        
        for key in keys {
            print(key.inYellow)
        }
    }

}
