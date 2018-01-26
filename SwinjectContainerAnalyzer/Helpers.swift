//
//  Helpers.swift
//  SwinjectContainerAnalyzer
//
//  Created by Søren Nielsen on 26/01/2018.
//  Copyright © 2018 Sonderby Inc. All rights reserved.
//

import Foundation

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        if index >= count {
            return nil
        }

        return self[index]
    }
}

enum ContainerAction {
    case registration
    case resolve
}

private let registerRegex = try! NSRegularExpression(pattern: "\\.register\\((\\w*).self\\)", options: [])
private let resolveRegex = try! NSRegularExpression(pattern: "\\.resolve\\((\\w*).self\\)", options: [])

struct TypeMatch {
    let file: String
    let type: String
    let line: Int
    let containerAction: ContainerAction
}

let containerRegexes = [
    resolveRegex: ContainerAction.resolve,
    registerRegex: ContainerAction.registration
]

typealias TypeAction = (name: String, containerAction: ContainerAction)

func matches(with regexPairs: [NSRegularExpression: ContainerAction],
             in line: String) -> [TypeAction] {
    let range = NSRange(location: 0, length: line.count)

    return regexPairs.map { regexPair -> TypeAction? in
        let regex = regexPair.key
        let containerAction = regexPair.value

        let registerMatches = regex.matches(in: line, range: range)

        if registerMatches.isEmpty {
            return nil
        }

        let match = registerMatches.first!
        let typeNameRange = match.range(at: 1)
        let lineNSString = line as NSString
        let typeName = lineNSString.substring(with: typeNameRange)

        return (name: typeName, containerAction: containerAction)
    }.flatMap { $0 }
}

func matches(in files: [String]) -> [TypeMatch] {
    return files.map { swiftFile -> [TypeMatch] in
        var inComment = false

        do {
            let lines = try String(contentsOfFile: swiftFile).components(separatedBy: .newlines)
            return lines.enumerated().map { object -> [TypeMatch] in
                let line = object.element.trimmingCharacters(in: .whitespaces)

                if line.hasPrefix("/*") {
                    inComment = true
                }

                if line.hasSuffix("*/") {
                    inComment = false
                }

                if inComment {
                    return []
                }

                if line.hasPrefix("//") {
                    return []
                }

                let containerMatches = matches(with: containerRegexes, in: line)
                return containerMatches.map { match in
                    return TypeMatch(file: swiftFile, type: match.name, line: object.offset+1, containerAction: match.containerAction)
                }
            }.flatMap { $0 }
        } catch {
            fatalError("Could not read file at path \(swiftFile)")
        }
    }.flatMap { $0 }
}
