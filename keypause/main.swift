//
//  main.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz
import ApplicationServices


func printUsage() {
    print("""
    Keypause \(appVersion)

    Usage: keypause [options]

    Locks your keyboard (and optionally mouse/trackpad) until you press two \
    activator keys together again.

    Options:
      --check-permissions   Check whether Accessibility permission is granted
                            and exit (0 if granted, 1 if not). Does not
                            install any event taps or read input.
      --keys=KEY1+KEY2      Set the activator combo from the command line
                            instead of the interactive prompt, e.g.
                            --keys=leftcommand+leftshift. Key names match
                            what keypause prints during setup (case
                            insensitive), plus aliases like cmd, shift,
                            option/alt, control/ctrl, and caps. A raw
                            keycode number can also be given prefixed with
                            #, e.g. --keys=#55+#56.
      --lock-mouse          Also lock the trackpad/mouse while locked,
                            instead of the interactive prompt.
      -h, --help            Print this help message and exit.
      -v, --version         Print the version and exit.
    """)
}

func checkPermissions() -> Never {
    let trusted = AXIsProcessTrusted()
    if trusted {
        print("Accessibility permission: granted")
        exit(0)
    } else {
        print("Accessibility permission: not granted")
        exit(1)
    }
}

func main() {
    let arguments = CommandLine.arguments.dropFirst()

    if arguments.contains("--check-permissions") {
        checkPermissions()
    }
    if arguments.contains("-v") || arguments.contains("--version") {
        print(appVersion)
        exit(0)
    }
    if arguments.contains("-h") || arguments.contains("--help") {
        printUsage()
        exit(0)
    }

    checkAccessibilityPermission()

    let keysArgument = arguments
        .first { $0.hasPrefix("--keys=") }
        .map { String($0.dropFirst("--keys=".count)) }

    if let keysArgument {
        guard let (key1, key2) = parseActivatorKeyPair(keysArgument) else {
            print("Invalid --keys value \"\(keysArgument)\". Use two different keys separated by '+', e.g. --keys=leftcommand+leftshift.")
            exit(1)
        }
        activatorKey1 = key1
        activatorKey2 = key2
        print("Keypause \(appVersion)")
        print("Activator keys set to \(keyDescription(key1)) and \(keyDescription(key2)) via --keys.")
    } else {
        selectActivatorKeys()
    }

    guard activatorKey1 != nil, activatorKey2 != nil else {
        print("Failed to set activator keys.")
        exit(1)
    }

    if arguments.contains("--lock-mouse") {
        shouldLockMouse = true
        print("Trackpad/mouse locking enabled via --lock-mouse.")
    } else {
        shouldLockMouse = promptYesNo("Also lock trackpad/mouse while locked?", defaultYes: false)
    }

    guard let createdKeyboardTap = CGEvent.tapCreate(
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
    keyboardTap = createdKeyboardTap

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

    let keyboardRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, createdKeyboardTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), keyboardRunLoopSource, .commonModes)
    CGEvent.tapEnable(tap: createdKeyboardTap, enable: true)

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
