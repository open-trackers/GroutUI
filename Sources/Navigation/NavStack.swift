//
//  NavStack.swift
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

public struct NavStack<Destination, Content>: View
    where Destination: View, Content: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var manager: CoreDataStack
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Parameters

    @Binding private var navData: Data?
    private var destination: (GroutRouter, GroutRoute) -> Destination
    private var content: () -> Content

    public init(navData: Binding<Data?>,
                @ViewBuilder destination: @escaping (GroutRouter, GroutRoute) -> Destination = { GroutDestination($1).environmentObject($0) },
                @ViewBuilder content: @escaping () -> Content)
    {
        _navData = navData
        self.destination = destination
        self.content = content
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: NavStack<Destination, Content>.self))

    @StateObject private var router: GroutRouter = .init()

    // MARK: - Views

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .environmentObject(router)
                .environmentObject(manager)
                .environment(\.managedObjectContext, viewContext)
                .navigationDestination(for: GroutRoute.self, destination: destinationAction)
                .onChange(of: scenePhase, perform: scenePhaseChangeAction)
        }
        .interactiveDismissDisabled() // NOTE: needed to prevent home button from dismissing sheet
    }

    // obtain the view for the given route
    // NOTE: may be a view that exists exclusively in an iOS or watchOS project
    private func destinationAction(_ route: GroutRoute) -> some View {
        destination(router, route)
    }

    private func scenePhaseChangeAction(_ foo: ScenePhase) {
        switch foo {
        case .background, .inactive:
            logger.notice("\(#function): scenePhase going background/inactive; saving navigation state")
            do {
                navData = try router.saveNavigationState()
                logger.debug("\(#function): saved path \(router.path)")
            } catch {
                logger.error("\(#function): unable to save navigation state, \(error)")
            }
        case .active:
            if let navData {
                logger.notice("\(#function): scenePhase going active; restoring navigation state")
                router.restoreNavigationState(from: navData)
                logger.debug("\(#function): restored path \(router.path)")
            } else {
                logger.notice("\(#function): scenePhase going active; but no data to restore navigation state")
            }
        @unknown default:
            logger.notice("\(#function): scenePhase not recognized")
        }
    }
}
