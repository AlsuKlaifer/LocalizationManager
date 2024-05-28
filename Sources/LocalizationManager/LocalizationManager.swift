//
//  LocalizationManager.swift
//
//
//  Created by Alsu Faizova on 12.05.2024.
//

import Foundation

@main
public struct LocalizationManager {

    // MARK: Public

    public static func main() {
        guard let dir = Utils.projectDirectory else {
            print("Project can't be found!".inRed)
            print("Please enter project directory as argument!".inYellow)
            return
        }

        if Utils.localizableFiles.isEmpty {
            print("Project doesn't contain localizable files".inRed)
            addLanguages(in: dir)
        } else {
            getLanguages(in: dir)
        }

        printTable(info)
        askForUserInput()
    }

    // MARK: Private

    private static let info = """
    a Add new key
    m Modify key
    r Remove key
    sh Show all keys
    gen Generate strings enum
    syn Synchronize all localizable files
    el Existing languages
    al Add new language
    rl Remove language
    e Exit
    """
    
    private static func askForUserInput() {
        guard let dir = Utils.projectDirectory else { return }
        while true {
            let operation = readLine()
            switch operation?.lowercased() {
            case "a":
                LocaleManager.tryAddingKey()
            case "m":
                LocaleManager.tryModifyingKey()
            case "r":
                LocaleManager.tryRemovingKey()
            case "sh":
                LocaleManager.printKeys()
            case "gen":
                StructGeneration.generateEnum()
            case "syn":
                Synchronization.synchronizeAllLocalizableFiles()
            case "al":
                addLanguages(in: dir)
            case "el":
                getLanguages(in: dir)
            case "rl":
                // remove language
                continue
            case "?":
                printTable(info)
            case "e", "exit":
                exit(0)
            default:
                print("Enter ? to get information about commands".inYellow)
            }
        }
    }

    private static func addLanguages(in directory: String) {
        print("Please enter the languages (comma-separated) to create localizable files:".inYellow)
        if let input = readLine() {
            let languages = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            for language in languages {
                Utils.createLocalizableFile(for: language, in: directory)
            }
        } else {
            print("No input received. Exiting.".inRed)
        }
    }

    private static func getLanguages(in directory: String) {
        print("Existing languages:".inYellow)
        for file in Utils.localizableFiles {
            let language = file.components(separatedBy: ".").first ?? ""
            print(language)
        }
    }

    private static func printTable(_ text: String) {
        let lines = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        var commands: [(String, String)] = []

        for line in lines {
            if line.isEmpty {
                continue
            }
            
            let components = line.split(separator: " ", maxSplits: 1).map { String($0) }
            if components.count == 2 {
                let command = components[0]
                let description = components[1]
                commands.append((command, description))
            }
        }

        guard !commands.isEmpty else { return }

        let commandColumnWidth = max(commands.map { $0.0.count }.max() ?? 0, "Command".count)
        let descriptionColumnWidth = max(commands.map { $0.1.count }.max() ?? 0, "Description".count)

        let header = String(repeating: " ", count: commandColumnWidth - "Command".count) + "Command | Description"
        print(header.inYellow)
        print(String(repeating: "-", count: commandColumnWidth + descriptionColumnWidth + 3))

        for (command, description) in commands {
            let commandPadding = String(repeating: " ", count: commandColumnWidth - command.count)
            let row = "\(command)\(commandPadding) | \(description)"
            print(row)
        }

        print(String(repeating: "-", count: commandColumnWidth + descriptionColumnWidth + 3))
    }
}
