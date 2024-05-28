//
//  String+Extensions.swift
//  
//
//  Created by Alsu Faizova on 13.05.2024.
//

import Foundation

extension String {
    var quoted: String {
        "\"\(self)\""
    }

    var inRed: String {
        "\u{001B}[0;31m \(self) \u{001B}[0;0m"
    }

    var inYellow: String {
        "\u{001B}[0;33m \(self) \u{001B}[0;0m"
    }

    var inGreen: String {
        "\u{001B}[0;32m \(self) \u{001B}[0;0m"
    }

    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
