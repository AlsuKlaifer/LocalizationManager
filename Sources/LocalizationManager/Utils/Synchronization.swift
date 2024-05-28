//
//  Synchronization.swift
//
//
//  Created by Alsu Faizova on 17.05.2024.
//

import Foundation

enum Synchronization {
    static func synchronizeAllLocalizableFiles() {
        let localizableFilePaths = Utils.localizableFiles
        var allKeysExistInAllFiles = true

        // Синхронизация каждого файла
        for filePath in localizableFilePaths {
            if !synchronizeFile(at: filePath) {
                allKeysExistInAllFiles = false
            }
        }

        if allKeysExistInAllFiles {
            print("All keys exist in all languages".inGreen)
        }
    }

    static func synchronizeFile(at filePath: String) -> Bool {
        let localizableFilePaths = Utils.localizableFiles
        var allKeys = Set<String>()

        // Извлекаем ключи из всех файлов
        for path in localizableFilePaths {
            let content = Utils.contentOf(file: path)
            let keys = Utils.extractKeys(from: content)
            allKeys.formUnion(keys)
        }

        let content = Utils.contentOf(file: filePath)
        let keysInFile = Set(Utils.extractKeys(from: content))
        let missingKeys = allKeys.subtracting(keysInFile)

        let lang = Utils.languageFromFilePath(filePath)

        // Проверяем отсутствие ключей и запрашиваем значения у пользователя
        if missingKeys.isEmpty {
            return true
        } else {
            print("Missing keys in \(lang.uppercased()) language".inRed)
            for key in missingKeys {
                print("Enter value for key '\(key)': ".inYellow, terminator: "")
                if let value = readLine(), !value.isEmpty {
                    Utils.addKey(key: key, value: value, to: filePath)
                } else {
                    print("No value entered for key '\(key)' in \(lang.uppercased()) language".inRed)
                }
            }
            return false
        }
    }
}
