//
//  CommandController.swift
//
//
//  Created by Alsu Faizova on 12.05.2024.
//

import Foundation

@main
public struct CommandController {

    // MARK: Public

    public static func main() {
        guard Utils.projectDirectory != nil else {
            print("Project can't be found!".inRed)
            print("Please enter project directory as argument!".inYellow)
            return
        }

        if Utils.localizableFiles.isEmpty {
            print("Project doesn't contain localizable files".inRed)
            LanguageManager.addLanguages()
        } else {
            LanguageManager.getLanguages()
        }

        printTable(info)
        askForUserInput()
    }

    static func currentFilePath(file: String = #file) -> String {
        return file
    }

    // MARK: Private

    private static var info: String {
        guard let text = Converter.readJSONFile(at: "commands.json") else { return "" }
        return text
    }
    
    private static func askForUserInput() {
        while true {
            let operation = readLine()
            switch operation?.lowercased() {
            case "a":
                LocalizationController.tryAddingKey()
            case "m":
                LocalizationController.tryModifyingKey()
            case "r":
                LocalizationController.tryRemovingKey()
            case "sh":
                LocalizationController.printKeys()
            case "gen":
                StructGeneration.generateStruct()
            case "syn":
                Synchronization.synchronizeAllLocalizableFiles()
            case "rep":
                CodeUpdater.replaceStringsWithStructuredVariables()
            case "al":
                LanguageManager.addLanguages()
            case "el":
                LanguageManager.getLanguages()
            case "rl":
                LanguageManager.deleteLanguage()
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
