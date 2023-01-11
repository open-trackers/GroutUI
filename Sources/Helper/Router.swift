//
//  Router.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "Router")

@MainActor public final class Router<T>: ObservableObject
    where T: Hashable & CustomStringConvertible
{
    // MARK: - Parameters

    public init() {}

    // MARK: - Locals

    @Published public var path: [T] = []
//    {
//        didSet {
//            logger.debug("didSet path=\(self.path)")
//        }
//    }

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - Helpers

    func popToRootView() {
        path = .init()
    }
}

public extension Router where T: Codable {
    func saveNavigationState() throws -> Data? {
        // logger.debug("SAVING path=\(self.path)")
        try encoder.encode(path)
    }

    func restoreNavigationState(from data: Data) {
        do {
            path = try decoder.decode([T].self, from: data)
        } catch {
            logger.error("unable to restore navigation state, \(error)")
            path = []
        }
        // logger.debug("RESTORED path=\(self.path)")
    }
}
