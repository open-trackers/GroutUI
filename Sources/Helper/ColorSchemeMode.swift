//
//  ColorSchemeMode.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public enum ColorSchemeMode: Int, CaseIterable {
    case automatic
    case light
    case dark

    public var description: String {
        switch self {
        case .automatic:
            return "Auto"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .automatic:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
