//
//  GroutRoute.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import TrackerUI

public typealias GroutRouter = Router<GroutRoute>

/// NOTE: routineRunDetail is presently iOS only, requiring injection of view into NavStack.
public enum GroutRoute: Hashable, Codable {
    case settings
    case about
    case routineDetail(_ routineUri: URL)
    case exerciseDetail(_ exerciseUri: URL)
    case exerciseList(_ routineUri: URL)
    case routineRunDetail(_ routineRunUri: URL)

    private func uriSuffix(_ uri: URL) -> String {
        "[\(uri.absoluteString.suffix(12))]"
    }
}
