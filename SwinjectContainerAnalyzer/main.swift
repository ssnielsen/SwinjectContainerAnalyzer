//
//  main.swift
//  SwinjectContainerAnalyzer
//
//  Created by Søren Nielsen on 26/01/2018.
//  Copyright © 2018 Sonderby Inc. All rights reserved.
//

import Foundation
import Darwin

guard let path = CommandLine.arguments[safeIndex: 1] else {
    fatalError("First argument must be the path")
}

let isStrict = CommandLine.arguments.contains("--strict")

// All files at 'path'
let files = FileManager.default.enumerator(atPath: path)

// All swift files at 'path'
let swiftFiles = files?
    .flatMap { $0 as? String }
    .filter { $0.hasSuffix(".swift") }
    .map { "\(path)/\($0)" }
    ?? []

let containerActions = matches(in: swiftFiles)
let groupedContainerActions = Dictionary.init(grouping: containerActions, by: { $0.containerAction })

// All container 'registrations' in given swift files
let registrations = groupedContainerActions[.registration] ?? []

// All container 'resolves' in given swift files
let resolves = groupedContainerActions[.resolve] ?? []

// Resolves that are not matched with a registration
let unregisteredResolves = resolves.filter { resolve in
    !registrations.contains { registration in registration.type == resolve.type }
}

if unregisteredResolves.isEmpty {
    exit(0)
} else {
    unregisteredResolves.forEach { resolve in
        // Print to stdout
        fputs("\(resolve.file):\(resolve.line): warning: Resolve of type \(resolve.type) not registered\n", __stdoutp)
    }

    exit(isStrict ? 1 : 0)
}
