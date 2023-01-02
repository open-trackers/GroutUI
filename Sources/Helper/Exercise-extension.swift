//
//  Exercise-extension.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import GroutLib

public extension Exercise {
    var canAdvance: Bool {
        !isDone && !atMax
    }

    var atMax: Bool {
        intensityMaxValue <= lastIntensity
    }
}
