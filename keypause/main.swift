//
//  main.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz


func main() {
    checkAccessibilityPermission()

    selectActivatorKeys()

    guard activatorKey1 != nil, activatorKey2 != nil else {
        print("Failed to set activator keys.")
        exit(1)
    }

    shouldLockMouse = promptYesNo("Also lock trackpad/mouse while locked?", defaultYes: false)

    guard let keyboardTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue)   |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << nxSystemDefinedEventType)
        ),
        callback: eventCallback,
        userInfo: nil
    ) else {
        print("Failed to create event tap. Make sure Accessibility permissions are enabled.")
        exit(1)
    }

    var mouseTap: CFMachPort?
    if shouldLockMouse {
        mouseTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mouseEventsMask(),
            callback: mouseEventCallback,
            userInfo: nil
        )
        if mouseTap == nil {
            print("Warning: Failed to create mouse/trackpad event tap. Keyboard locking will still work.")
        }
    }

    let keyboardRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyboardTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), keyboardRunLoopSource, .commonModes)
    CGEvent.tapEnable(tap: keyboardTap, enable: true)

    var mouseRunLoopSource: CFRunLoopSource?
    if let mouseTap {
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseTap, 0)
        mouseRunLoopSource = src
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: mouseTap, enable: true)
    }

    print("Running. Use your two activator keys together to lock/unlock.")
    CFRunLoopRun()

    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), keyboardRunLoopSource, .commonModes)
    if let src = mouseRunLoopSource {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, .commonModes)
    }
}

main()
