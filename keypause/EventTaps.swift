//
//  EventTaps.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz


let nxSystemDefinedEventType: UInt32 = 14

func setupEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    if type == .flagsChanged {
        guard let mod = modifierForFlagsAndKeyCode(event.flags, keyCode: keyCode) else { return Unmanaged.passUnretained(event) }
        let keyIsDown = (event.flags.rawValue & mod.rawValue) != 0
        if !keyIsDown { return Unmanaged.passUnretained(event) }
        switch setupPhase {
        case .settingKey1:
            activatorKey1 = .modifier(mod, keyCode)
            print("First activator key set to \(keyDescription(.modifier(mod, keyCode))) (\(keyCode)).")
            print("Press your second activator key.")
            setupPhase = .settingKey2
        case .settingKey2:
            if activatorKey1 == .modifier(mod, keyCode) {
                print("Second activator key must be different from the first. Press a different key.")
                return Unmanaged.passUnretained(event)
            }
            activatorKey2 = .modifier(mod, keyCode)
            print("Second activator key set to \(keyDescription(.modifier(mod, keyCode))) (\(keyCode)).")
            print("Use both keys together to lock keyboard.")
            setupPhase = .running
            CFRunLoopStop(CFRunLoopGetCurrent())
        case .running: break
        }
        return nil
    } else if type == .keyDown {
        switch setupPhase {
        case .settingKey1:
            activatorKey1 = .keyCode(keyCode)
            print("First activator key set to \(keyDescription(.keyCode(keyCode))) (\(keyCode)).")
            print("Press your second activator key.")
            setupPhase = .settingKey2
        case .settingKey2:
            if activatorKey1 == .keyCode(keyCode) {
                print("Second activator key must be different from the first. Press a different key.")
                return Unmanaged.passUnretained(event)
            }
            activatorKey2 = .keyCode(keyCode)
            print("Second activator key set to \(keyDescription(.keyCode(keyCode))) (\(keyCode)).")
            print("Use both keys together to lock/unlock keyboard.")
            setupPhase = .running
            CFRunLoopStop(CFRunLoopGetCurrent())
        case .running: break
        }
        return nil
    }
    return Unmanaged.passUnretained(event)
}

func matchesActivatorEvent(_ event: CGEvent, type: CGEventType, activator: ActivatorKey) -> Bool {
    let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    if type == .flagsChanged {
        switch activator {
        case .modifier(let mask, let aCode):
            guard let mod = modifierForFlagsAndKeyCode(event.flags, keyCode: keyCode) else { return false }
            return mod == mask && keyCode == aCode
        default: return false
        }
    } else if type == .keyDown || type == .keyUp {
        switch activator {
        case .keyCode(let aCode):
            return keyCode == aCode
        default: return false
        }
    }
    return false
}

// MARK: - Keyboard event tap

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let keyboardTap {
            CGEvent.tapEnable(tap: keyboardTap, enable: true)
        }
        return nil
    }

    // Hardware media/brightness/volume/Mission Control keys (F-keys not acting as
    // standard function keys) arrive as NX_SYSDEFINED events, not keyDown/keyUp/
    // flagsChanged, so they bypass all the activator/key-tracking logic below.
    if type.rawValue == nxSystemDefinedEventType {
        return keyboardLocked ? nil : Unmanaged.passUnretained(event)
    }

    guard let activatorKey1 = activatorKey1, let activatorKey2 = activatorKey2 else {
        return Unmanaged.passUnretained(event)
    }

    let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    let flags = event.flags

    // Track normal key presses
    if type == .keyDown {
        pressedKeyCodes.insert(keyCode)
    } else if type == .keyUp {
        pressedKeyCodes.remove(keyCode)
    } else if type == .flagsChanged {
        // Modifier keys: update pressedKeyCodes for left/right modifiers
        let keyIsDown = (modifierForFlagsAndKeyCode(flags, keyCode: keyCode) != nil) && (flags.rawValue & (modifierForFlagsAndKeyCode(flags, keyCode: keyCode)?.rawValue ?? 0) != 0)
        if keyIsDown {
            pressedKeyCodes.insert(keyCode)
        } else {
            pressedKeyCodes.remove(keyCode)
        }
    }

    // Are both activators currently pressed?
    let bothPressedNow = isActivatorPressed(activatorKey1, flags: flags, pressedKeyCodes: pressedKeyCodes)
        && isActivatorPressed(activatorKey2, flags: flags, pressedKeyCodes: pressedKeyCodes)

    // Toggling: If both become pressed, set awaitingRelease
    if bothPressedNow && !awaitingRelease {
        awaitingRelease = true
    }

    // Toggling: If both were pressed, and then both are released, toggle lock
    let bothReleasedNow = !isActivatorPressed(activatorKey1, flags: flags, pressedKeyCodes: pressedKeyCodes)
        && !isActivatorPressed(activatorKey2, flags: flags, pressedKeyCodes: pressedKeyCodes)

    if awaitingRelease && bothReleasedNow {
        keyboardLocked.toggle()

        // Update pinned cursor position when entering or leaving lock
        if keyboardLocked && shouldLockMouse {
            pinnedCursorPosition = CGEvent(source: nil)?.location
        } else {
            pinnedCursorPosition = nil
        }

        print("")
        print("--- \(keyboardLocked ? (shouldLockMouse ? "Keyboard and Mouse locked" : "Keyboard locked") : "Unlocked") ---")
        awaitingRelease = false
    }

    // If locked, block all keys (including activators, so the lock combo itself doesn't leak through)
    if keyboardLocked {
        // Explicitly suppress Fn and F-keys (top row) while locked
        if type == .keyDown || type == .keyUp || type == .flagsChanged {
            if keyCode == 63 || isFunctionKey(keyCode) {
                return nil
            }
        }
        return nil // suppress all other events as before
    }

    // Unlocked: allow all keys through
    return Unmanaged.passUnretained(event)
}

// MARK: - Mouse event tap

func mouseEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let mouseTap {
            CGEvent.tapEnable(tap: mouseTap, enable: true)
        }
        return nil
    }

    // While locked, suppress mouse/trackpad events and pin cursor position
    if keyboardLocked && shouldLockMouse {
        // If we have a pinned position, warp back on any move/drag/scroll
        if let pinned = pinnedCursorPosition {
            switch type {
            case .mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged, .scrollWheel:
                CGWarpMouseCursorPosition(pinned)
                // boolean_t is Int32. Pass 1 to associate (true), 0 to disassociate (false).
                CGAssociateMouseAndMouseCursorPosition(1)
            default:
                break
            }
        }
        // Suppress all mouse events while locked (clicks, moves, scrolls)
        return nil
    }
    return Unmanaged.passUnretained(event)
}

// Trackpad gesture event types (rotate, swipe-to-navigate, magnify/pinch-zoom,
// smart zoom, and the begin/end gesture bracket events). These aren't exposed
// as CGEventType cases, but they share the same NX event-type numbering space,
// so we reference them by raw value the same way nxSystemDefinedEventType does.
let nxGestureEventType: UInt32 = 29
let nxMagnifyEventType: UInt32 = 30
let nxSwipeEventType: UInt32 = 31
let nxRotateEventType: UInt32 = 18
let nxBeginGestureEventType: UInt32 = 19
let nxEndGestureEventType: UInt32 = 20
let nxSmartMagnifyEventType: UInt32 = 32

// Helper to build a mask for common mouse events
func mouseEventsMask() -> CGEventMask {
    let types: [CGEventType] = [
        .leftMouseDown, .leftMouseUp,
        .rightMouseDown, .rightMouseUp,
        .otherMouseDown, .otherMouseUp,
        .mouseMoved,
        .leftMouseDragged, .rightMouseDragged, .otherMouseDragged,
        .scrollWheel
    ]
    let rawTypes: [UInt32] = [
        nxGestureEventType, nxMagnifyEventType, nxSwipeEventType,
        nxRotateEventType, nxBeginGestureEventType, nxEndGestureEventType,
        nxSmartMagnifyEventType
    ]
    var mask = types.reduce(CGEventMask(0)) { partial, type in
        partial | (1 << type.rawValue)
    }
    mask = rawTypes.reduce(mask) { partial, rawType in
        partial | (1 << rawType)
    }
    return mask
}
