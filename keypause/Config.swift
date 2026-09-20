//
//  Config.swift
//  keypause
//
//  Created by Elijah Friedman on 9/20/26.
//

import Foundation

let configDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config", isDirectory: true)
    .appendingPathComponent("keypause", isDirectory: true)

let configFileURL = configDirectoryURL.appendingPathComponent("config", isDirectory: false)

struct KeypauseConfig {
    var keys: String?
    var lockMouse: Bool?
    var enabled: Bool?
}

func loadConfig() -> KeypauseConfig {
    var config = KeypauseConfig()
    guard let contents = try? String(contentsOf: configFileURL, encoding: .utf8) else {
        return config
    }

    for rawLine in contents.split(separator: "\n") {
        let line = rawLine.trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty, !line.hasPrefix("#") else { continue }

        let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        let key = parts[0].trimmingCharacters(in: .whitespaces)
        let value = parts[1].trimmingCharacters(in: .whitespaces)

        switch key {
        case "keys":
            config.keys = value
        case "lock-mouse":
            config.lockMouse = (value == "true")
        case "enabled":
            config.enabled = (value == "true")
        default:
            break
        }
    }

    return config
}

func writeConfig(_ config: KeypauseConfig) {
    var lines: [String] = []
    if let keys = config.keys {
        lines.append("keys=\(keys)")
    }
    if let lockMouse = config.lockMouse {
        lines.append("lock-mouse=\(lockMouse)")
    }
    if let enabled = config.enabled {
        lines.append("enabled=\(enabled)")
    }
    let contents = lines.map { "\($0)\n" }.joined()

    do {
        try FileManager.default.createDirectory(at: configDirectoryURL, withIntermediateDirectories: true)
        try contents.write(to: configFileURL, atomically: true, encoding: .utf8)
    } catch {
        print("Warning: Failed to save config to \(configFileURL.path): \(error.localizedDescription)")
    }
}

// Turns an ActivatorKey back into the canonical name string that parseActivatorKey
// can read back, so it can round-trip through the config file.
func activatorKeyStorageName(_ key: ActivatorKey) -> String {
    switch key {
    case .keyCode(let code):
        return keycodeName(code)
    case .modifier(_, let code):
        return keycodeName(code)
    }
}
