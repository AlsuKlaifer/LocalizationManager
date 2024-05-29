//
//  AST.swift
//
//
//  Created by Alsu Faizova on 24.05.2024.
//

import Foundation

struct AST {

    enum Token {
        case identifier(String)
        case stringLiteral(String)
        case assignment
        case unknown
    }

    static func getStringLiteral(from line: String) -> String? {
        let tokens = tokenize(line)
        let (_, right) = parseAST(tokens: tokens)

        if case let .stringLiteral(stringLiteral)? = right {
            return stringLiteral
        }
        return nil
    }
    
    // Функция для токенизации строки
    private static func tokenize(_ line: String) -> [Token] {
        var tokens: [Token] = []
        var currentToken = ""

        for char in line {
            switch char {
            case "\"":
                if !currentToken.isEmpty {
                    tokens.append(.stringLiteral(currentToken))
                    currentToken = ""
                }
            case "=":
                if !currentToken.isEmpty {
                    tokens.append(.identifier(currentToken))
                    currentToken = ""
                }
                tokens.append(.assignment)
            case " ", "\t", "\n":
                if !currentToken.isEmpty {
                    tokens.append(.identifier(currentToken))
                    currentToken = ""
                }
            default:
                currentToken.append(char)
            }
        }

        if !currentToken.isEmpty {
            tokens.append(.identifier(currentToken))
        }

        return tokens
    }

    private static func parseIdentifier(tokens: [Token], currentIndex: inout Int) -> Token? {
        if currentIndex < tokens.count, case .identifier = tokens[currentIndex] {
            let identifier = tokens[currentIndex]
            currentIndex += 1
            return identifier
        }
        return nil
    }

    private static func parseStringLiteral(tokens: [Token], currentIndex: inout Int) -> Token? {
        if currentIndex < tokens.count, case .stringLiteral = tokens[currentIndex] {
            let literal = tokens[currentIndex]
            currentIndex += 1
            return literal
        }
        return nil
    }

    private static func parseAST(tokens: [Token]) -> (Token?, Token?) {
        var currentIndex = 0

        let left = parseIdentifier(tokens: tokens, currentIndex: &currentIndex)
        if currentIndex < tokens.count, case .assignment = tokens[currentIndex] {
            currentIndex += 1
            let right = parseStringLiteral(tokens: tokens, currentIndex: &currentIndex)
            return (left, right)
        }

        return (nil, nil)
    }
}
