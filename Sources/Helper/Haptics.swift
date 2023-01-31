//
//  Haptics.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

#if os(iOS)
    import UIKit
#endif

#if os(watchOS)
    import WatchKit
#endif

public struct Haptics {
    public enum Action: Int {
        case startingRoutine
        case stoppingRoutine
        case routineCompleted // when last exercise of a routine has been completed
        case click // most button clicks/presses
        case longPress // long press button
        case warning // for when user is prompted with an alert
    }

    private init() {}

    public static func play(_ action: Action = .click) {
        #if os(iOS)
            // iOS: FeedbackStyle
            // case light = 0
            // case medium = 1
            // case heavy = 2
            // case soft = 3
            // case rigid = 4

            // iOS: FeedbackType
            // case success = 0
            // case warning = 1
            // case error = 2
            switch action {
            case .startingRoutine:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .stoppingRoutine:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .routineCompleted:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .click:
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            case .longPress:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        #elseif os(watchOS)
            // watchOS: WKHapticType
            // case notification = 0
            // case directionUp = 1
            // case directionDown = 2
            // case success = 3 // escalating ding
            // case failure = 4
            // case retry = 5
            // case start = 6 // single ding
            // case stop = 7 // double ding
            // case click = 8
            let device = WKInterfaceDevice.current()
            switch action {
            case .startingRoutine:
                device.play(.start)
            case .stoppingRoutine:
                device.play(.stop)
            case .routineCompleted:
                device.play(.success)
            case .click:
                device.play(.click)
            case .longPress:
                device.play(.directionUp)
            case .warning:
                device.play(.notification)
            }
        #endif
    }
}
