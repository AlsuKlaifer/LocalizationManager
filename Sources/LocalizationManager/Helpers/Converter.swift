//
//  Converter.swift
//
//
//  Created by Alsu Faizova on 28.05.2024.
//

import Foundation

struct Converter {
    static func readJSONFile(at fileName: String) -> String? {
        let fileManager = FileManager.default
        let path = getResourcesFilePath(resourceFileName: fileName)

        guard fileManager.fileExists(atPath: path) else { return nil }
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Failed to decode JSON data to String")
                return nil
            }
        } catch {
            print("Failed to read file at path: \(path) with error: \(error)")
            return nil
        }
    }

    private static func getResourcesFilePath(resourceFileName: String) -> String {
        let currentFilePath = #file
        let pathComponents = currentFilePath.split(separator: "/")

        let count = pathComponents.count
        var components: [String] = []
        
        for index in 0..<count - 2 {
            let component = String(pathComponents[index])
            components.append(component)
        }

        components.append("Resources")
        components.append(resourceFileName)
        
        let resourceFilePath = components.joined(separator: "/")
        return "/\(resourceFilePath)"
    }
}
