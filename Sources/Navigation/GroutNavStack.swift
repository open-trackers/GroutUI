//
//  GroutNavStack.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

public struct GroutNavStack<Destination, Content>: View
    where Destination: View, Content: View
{
    @EnvironmentObject private var manager: CoreDataStack

    // MARK: - Parameters

    @Binding private var navData: Data?
    private let stackIdentifier: String?
    private let destination: (GroutRouter, GroutRoute) -> Destination
    private let content: () -> Content

    public init(navData: Binding<Data?>,
                stackIdentifier: String? = nil,
                @ViewBuilder destination: @escaping (GroutRouter, GroutRoute) -> Destination = { GroutDestination($1).environmentObject($0) },
                @ViewBuilder content: @escaping () -> Content)
    {
        _navData = navData
        self.stackIdentifier = stackIdentifier
        self.destination = destination
        self.content = content
    }

    public var body: some View {
        BaseNavStack(navData: $navData,
                     stackIdentifier: stackIdentifier,
                     coreDataStack: manager,
                     destination: destination,
                     content: content)
            .environmentObject(manager)
    }
}
