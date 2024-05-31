//
//  XcodeProjectManager.swift
//
//
//  Created by Alsu Faizova on 30.05.2024.
//

import Foundation

struct XcodeProjectManager {

    static func addFileToProject(filePath: String) {
        do {
            guard let projectPath = Utils.projectDirectory else { return }
            let projectFile = "\(projectPath).xcodeproj"

            var projectFileContent = try String(contentsOfFile: projectFile, encoding: .utf8)
            
            // Generate a unique ID for the new file reference
            let newFileReferenceID = generateUniqueID()
            let newBuildFileID = generateUniqueID()

            let fileReference = """
            \(newFileReferenceID) /* \(filePath) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \(filePath); sourceTree = "<group>"; };
            """
            if let filesGroupRange = projectFileContent.range(of: "/* Begin PBXFileReference section */") {
                projectFileContent.insert(contentsOf: fileReference, at: filesGroupRange.upperBound)
            }

            let buildFile = """
            \(newBuildFileID) /* \(filePath) in Sources */ = {isa = PBXBuildFile; fileRef = \(newFileReferenceID) /* \(filePath) */; };
            """
            if let buildFilesGroupRange = projectFileContent.range(of: "/* Begin PBXBuildFile section */") {
                projectFileContent.insert(contentsOf: buildFile, at: buildFilesGroupRange.upperBound)
            }
            
            try projectFileContent.write(toFile: projectFile, atomically: true, encoding: .utf8)

        } catch { return }
    }

    private static func generateUniqueID() -> String {
        // Generate a pseudo-random unique ID (24 characters long)
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24).uppercased()
    }
}
