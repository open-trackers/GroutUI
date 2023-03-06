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

public enum GroutRoute: Hashable, Codable {
    case settings
    case about
    case routineDetail(_ routineUri: URL)
    case exerciseDetail(_ exerciseUri: URL)
    case exerciseList(_ routineUri: URL)
    case exerciseRunList(_ routineRunUri: URL)
    case exerciseDefaults

    private func uriSuffix(_ uri: URL) -> String {
        "[\(uri.absoluteString.suffix(12))]"
    }
}
