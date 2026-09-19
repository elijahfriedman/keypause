//
//  Setup.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz

func selectActivatorKeys() {
    print("Keypause "+appVersion)
    print("Press your first activator key.")

    guard let eventTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        ),
        callback: setupEventCallback,
        userInfo: nil
    ) else {
        print("Failed to create event tap for setup. Make sure Accessibility permissions are enabled.")
        exit(1)
    }

    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)

    while setupPhase != .running {
        CFRunLoopRun()
    }

    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
}

func promptYesNo(_ message: String, defaultYes: Bool = false) -> Bool {
    let defaultPrompt = defaultYes ? "Y/n" : "y/N"
    while true {
        print("\(message) (\(defaultPrompt)): ", terminator: "")
        fflush(stdout)
        guard let line = readLine() else { return defaultYes }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return defaultYes }
        if ["y", "yes"].contains(trimmed) {
            print("-> Yes")
            return true
        }
        if ["n", "no"].contains(trimmed) {
            print("-> No")
            return false
        }
        print("Please answer y or n.")
    }
}
