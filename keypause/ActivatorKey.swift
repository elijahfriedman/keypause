//
//  ActivatorKey.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz

enum ActivatorKey: Equatable {
    case keyCode(CGKeyCode)
    case modifier(CGEventFlags, CGKeyCode)
}

func keyDescription(_ key: ActivatorKey) -> String {
    switch key {
    case .keyCode(let code):
        return keycodeName(code)
    case .modifier(let flag, let keyCode):
        let side: String
        switch keyCode {
        case 54: side = "Right"
        case 55: side = "Left"
        case 56: side = "Left"
        case 60: side = "Right"
        case 58: side = "Left"
        case 61: side = "Right"
        case 59: side = "Left"
        case 62: side = "Right"
        default: side = ""
        }

        let base: String
        switch flag {
        case CGEventFlags.maskCommand: base = "Command"
        case CGEventFlags.maskShift: base = "Shift"
        case CGEventFlags.maskControl: base = "Control"
        case CGEventFlags.maskAlternate: base = "Option"
        case CGEventFlags.maskAlphaShift: base = "CapsLock"
        case CGEventFlags.maskSecondaryFn: base = "Fn"
        default: base = "Modifier(\(flag.rawValue))"
        }
        return side.isEmpty ? base : "\(side) \(base)"
    }
}

func keycodeName(_ keyCode: CGKeyCode) -> String {
    let names: [CGKeyCode: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G",
        6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q",
        13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1",
        19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=",
        25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 30: "]",
        31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 36: "Return",
        37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\",
        43: ",", 44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab",
        49: "Space", 50: "`", 51: "Delete", 53: "Escape",
        54: "RightCommand", 55: "LeftCommand", 56: "LeftShift", 57: "CapsLock",
        58: "LeftOption", 59: "LeftControl", 60: "RightShift", 61: "RightOption", 62: "RightControl",
        63: "Function", 64: "F17", 65: "KeypadDecimal", 67: "KeypadMultiply", 69: "KeypadPlus",
        71: "KeypadClear", 75: "KeypadDivide", 76: "KeypadEnter", 78: "KeypadMinus", 81: "KeypadEquals",
        82: "Keypad0", 83: "Keypad1", 84: "Keypad2", 85: "Keypad3", 86: "Keypad4", 87: "Keypad5",
        88: "Keypad6", 89: "Keypad7", 91: "Keypad8", 92: "Keypad9", 96: "F5", 97: "F6", 98: "F7",
        99: "F3", 100: "F8", 101: "F9", 103: "F11", 105: "F13", 106: "F16", 107: "F14", 109: "F10",
        111: "F12", 113: "F15", 114: "Help", 115: "Home", 116: "PageUp", 117: "ForwardDelete",
        118: "F4", 119: "End", 120: "F2", 121: "PageDown", 122: "F1", 123: "LeftArrow", 124: "RightArrow",
        125: "DownArrow", 126: "UpArrow"
    ]
    return names[keyCode] ?? "\(keyCode)"
}

func modifierForFlagsAndKeyCode(_ flags: CGEventFlags, keyCode: CGKeyCode) -> CGEventFlags? {
    switch keyCode {
    case 54: return .maskCommand
    case 55: return .maskCommand
    case 56: return .maskShift
    case 60: return .maskShift
    case 58: return .maskAlternate
    case 61: return .maskAlternate
    case 59: return .maskControl
    case 62: return .maskControl
    case 57: return .maskAlphaShift
    case 63: return .maskSecondaryFn
    default: return nil
    }
}

func isActivatorPressed(_ activator: ActivatorKey, flags: CGEventFlags, pressedKeyCodes: Set<CGKeyCode>) -> Bool {
    switch activator {
    case .keyCode(let k):
        return pressedKeyCodes.contains(k)
    case .modifier(let mask, let code):
        return flags.contains(mask) && pressedKeyCodes.contains(code)
    }
}

func isFunctionKey(_ keyCode: CGKeyCode) -> Bool {
    // Common Apple keycodes for F-keys on macOS keyboards
    // F1..F12 (122..123..etc present in names map), plus others present in the map above.
    let functionKeyCodes: Set<CGKeyCode> = [
        122, // F1
        120, // F2
        99,  // F3
        118, // F4
        96,  // F5
        97,  // F6
        98,  // F7
        100, // F8
        101, // F9
        109, // F10
        103, // F11
        111, // F12
        105, // F13
        107, // F14
        113, // F15
        106, // F16
        64   // F17
    ]
    return functionKeyCodes.contains(keyCode)
}
