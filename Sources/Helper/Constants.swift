//
//  Constants.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public let routineColor: Color = .accentColor
public let routineListItemTint: Color = .accentColor.opacity(0.2)

public let exerciseColorDarkBg: Color = .yellow.opacity(0.8)
public let exerciseColorLiteBg: Color = .primary
public let exerciseListItemTint: Color = .yellow.opacity(0.2)

public let stopColor: Color = .pink

public let exerciseDoneColor: Color = .green
public let exerciseUndoColor: Color = .green
public let exerciseAdvanceColor: Color = .mint
public let exerciseNextColor: Color = .blue

public let exerciseGearColor: Color = .gray
public let exerciseSetsColor: Color = .teal

public let titleColor: Color = .primary.opacity(0.8)
public let lastColor: Color = .primary.opacity(0.6)
public let disabledColor: Color = .secondary.opacity(0.4)
public let completedColor: Color = .secondary.opacity(0.5)

public let numberWeight: Font.Weight = .light

public let numberFont: Font = .title2

// How frequently to update time strings in RoutineCell
public let routineSinceUpdateSeconds: TimeInterval = 60

// How long to delay before showing edit sheet
public let editDelaySeconds: TimeInterval = 0.1

// How long to delay before showing first incomplete exercise, when starting routine
public let newFirstIncompleteSeconds: TimeInterval = 0.25

// public let colorSchemeModeKey = "colorScheme"
public let exportFormatKey = "exportFormat"

public let startRoutineActivityType = "org.openalloc.grout.run-routine"
public let userActivity_uriRepKey = "uriRep"

// storage keys
public let alwaysAdvanceOnLongPressKey = "alwaysAdvanceOnLongPress"
public let logToHistoryKey = "logToHistory"

public let controlTab = URL(string: "uri://control-panel")!

public let websiteDomain = "open-trackers.github.io"
public let copyright = "Copyright 2022, 2023 OpenAlloc LLC"

public let websiteURL = URL(string: "https://\(websiteDomain)")!
public let websitePrivacyURL = websiteURL.appending(path: "privacy")
public let websiteTermsURL = websiteURL.appending(path: "terms")

public let websiteAppURL = websiteURL.appending(path: "grt")
public let websiteAppTutorialURL = websiteAppURL.appending(path: "tutorial")

public let websitePlea: String =
    "As an open source project, we depend on our community of users. Please rate and review \(shortAppName) in the App Store!"

#if os(watchOS)
    public let shortAppName = "GRT"
#elseif os(iOS)
    public let shortAppName = "GRT+"
#endif
