//
//  Routes.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public typealias MyRouter = Router<MyRoutes>

public enum MyRoutes: Hashable, Codable, CustomStringConvertible {
    case settings
    case about
    case routineDetail(_ routineUriRep: URL)
    case exerciseDetail(_ exerciseUriRep: URL)
    case exerciseList(_ routineUriRep: URL)

    public var description: String {
        switch self {
        case .settings:
            return "Settings"
        case .about:
            return "About"
        case let .routineDetail(routineUri):
            return String("Routine Detail: \(uriSuffix(routineUri))")
        case let .exerciseDetail(exerciseUri):
            return String("Exercise Detail: \(uriSuffix(exerciseUri))")
        case let .exerciseList(routineUri):
            return String("Exercise List for routine=\(uriSuffix(routineUri))")
        }
    }

    private func uriSuffix(_ uri: URL) -> String {
        "[\(uri.absoluteString.suffix(12))]"
    }
}
