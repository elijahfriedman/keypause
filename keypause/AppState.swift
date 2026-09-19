//
//  AppState.swift
//  keypause
//
//  Created by Elijah Friedman on 9/19/26.
//

import Foundation
import Quartz

let appVersion = "0.1.1"

var activatorKey1: ActivatorKey?
var activatorKey2: ActivatorKey?

var keyboardLocked = false
var awaitingRelease = false

var shouldLockMouse = false

var pinnedCursorPosition: CGPoint?

var pressedKeyCodes = Set<CGKeyCode>()

var keyboardTap: CFMachPort?
var mouseTap: CFMachPort?

enum SetupPhase {
    case settingKey1
    case settingKey2
    case running
}

var setupPhase: SetupPhase = .settingKey1
