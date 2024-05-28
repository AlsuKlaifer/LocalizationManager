//
//  FileContent.swift
//
//
//  Created by Alsu Faizova on 16.05.2024.
//

typealias FileContent = [String]

extension FileContent {
    func contains(key: String) -> Bool {
        contains(where: { $0.contains(key.quoted) })
    }
}
