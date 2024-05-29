//
//  LanguageManager.swift
//
//
//  Created by Alsu Faizova on 20.05.2024.
//

import Foundation

struct LanguageManager {
    static func getLanguages() {
        print("Existing languages:".inYellow)
        for file in Utils.localizableFiles {
            let language = file.components(separatedBy: ".").first ?? ""
            print(language)
        }
    }

    static func addLanguages() {
        print("Please enter the languages (comma-separated) to create localizable files:".inYellow)
        if let input = readLine() {
            let languages = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            for language in languages {
                Utils.createLocalizableFile(for: language)
            }
        } else {
            print("No input received. Exiting.".inRed)
        }
    }

    static func deleteLanguage() {
        guard let dir = Utils.resourceDirectory else { return }
        let localizableFiles = Utils.localizableFiles
        guard !localizableFiles.isEmpty else {
            print("No localizable files found.".inRed)
            return
        }

        getLanguages()

        print("Enter the language code you want to delete:".inYellow)
        guard let languageCode = readLine(), !languageCode.isEmpty else {
            print("Language code cannot be empty.".inRed)
            return
        }

        let directoryPathToRemove = "\(dir)/\(languageCode).lproj"
        let fileManager = FileManager.default

        do {
            try fileManager.removeItem(atPath: directoryPathToRemove)
            print("Directory for \(languageCode.uppercased()) deleted successfully.".inGreen)
        } catch {
            print("Failed to delete directory: \(error)".inRed)
        }
    }
}
