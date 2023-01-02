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

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "NavStack"
)

public struct NavStack<Content>: View
    where Content: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Parameters

    private var name: String
    @Binding private var navData: Data?
    private var content: () -> Content

    public init(name: String,
                navData: Binding<Data?>,
                @ViewBuilder content: @escaping () -> Content)
    {
        self.name = name
        _navData = navData
        self.content = content
    }

    // MARK: - Locals

    @StateObject private var router: MyRouter = .init()

    // MARK: - Views

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .environmentObject(router)
                .environment(\.managedObjectContext, viewContext)
                .navigationDestination(for: MyRoutes.self) { route in
                    switch route {
                    case .settings:
                        SettingsForm()
                    case .about:
                        aboutView
//                    case .routines:
//                        // NOTE: not necessary while it's a root view
//                        RoutineList()
                    case let .routineDetail(routineURI):
                        if let routine = Routine.get(viewContext, forURIRepresentation: routineURI) {
                            RoutineDetail(routine: routine)
                                .environmentObject(router)
                                .environment(\.managedObjectContext, viewContext)
                        } else {
                            Text("Routine not available to display detail.")
                        }
                    case let .exerciseList(routineURI):
                        if let routine = Routine.get(viewContext, forURIRepresentation: routineURI) {
                            ExerciseList(routine: routine)
                                .environmentObject(router)
                                .environment(\.managedObjectContext, viewContext)
                        } else {
                            Text("Routine not available to display exercise list.")
                        }
                    case let .exerciseDetail(exerciseURI):
                        if let exercise = Exercise.get(viewContext, forURIRepresentation: exerciseURI) {
                            ExerciseDetail(exercise: exercise)
                                .environmentObject(router)
                                .environment(\.managedObjectContext, viewContext)
                        } else {
                            Text("Exercise not available to display detail.")
                        }
                    }
                }
                .onChange(of: scenePhase) {
                    switch $0 {
                    case .background, .inactive:
                        logger.notice("\(name): scenePhase going background/inactive; saving navigation state")
                        do {
                            navData = try router.saveNavigationState()
                            logger.debug("\(name): saved path \(router.path)")
                        } catch {
                            logger.error("\(name): unable to save navigation state, \(error)")
                        }
                    case .active:
                        if let navData {
                            logger.notice("\(name): scenePhase going active; restoring navigation state")
                            router.restoreNavigationState(from: navData)
                            logger.debug("\(name): restored path \(router.path)")
                        } else {
                            logger.notice("\(name): scenePhase going active; but no data to restore navigation state")
                        }
                    @unknown default:
                        logger.notice("\(name): scenePhase not recognized")
                    }
                }
        }
        .interactiveDismissDisabled() // NOTE: needed to prevent home button from dismissing sheet
    }

    private var aboutView: some View {
        AboutView(displayName: Bundle.main.displayName ?? "unknown",
                  releaseVersionNumber: Bundle.main.releaseVersionNumber ?? "unknown",
                  buildNumber: Bundle.main.buildNumber ?? "unknown",
                  websiteURL: websiteURL,
                  privacyURL: websitePrivacyURL,
                  termsURL: websiteTermsURL,
                  tutorialURL: websiteTutorialURL,
                  copyright: copyright) {
            AppIcon(name: "grt_icon")
        }
    }
}

// struct SettingsContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsContainerView()
//    }
// }
