//
//  GroutDestination.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib
import TrackerLib
import TrackerUI

// obtain the view for the specified route
public struct GroutDestination: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

//    private var router: GroutRouter
    private var route: GroutRoute

    public init(_ route: GroutRoute) {
//        self.router = router
        self.route = route
    }

    // @AppStorage(storageKeyQuickLogRecents) private var quickLogRecents: QuickLogRecentsDict = .init()

    public var body: some View {
        switch route {
        case .settings:
            // NOTE that this is only being used for watch settings
            if let appSetting = try? AppSetting.getOrCreate(viewContext) {
                GroutSettings(appSetting: appSetting, onRestoreToDefaults: {})
            } else {
                Text("Settings not available.")
            }
        case .about:
            aboutView
        case let .routineDetail(routineURI):
            if let routine: Routine = Routine.get(viewContext, forURIRepresentation: routineURI) {
                RoutineDetail(routine: routine)
                    .environmentObject(router)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Routine not available to display detail.")
            }
        case let .exerciseList(routineURI):
            if let routine: Routine = Routine.get(viewContext, forURIRepresentation: routineURI) {
                ExerciseList(routine: routine)
                    .environmentObject(router)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Routine not available to display exercise list.")
            }
        case let .exerciseDetail(exerciseURI):
            if let exercise: Exercise = Exercise.get(viewContext, forURIRepresentation: exerciseURI) {
                ExerciseDetail(exercise: exercise)
                    .environmentObject(router)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Exercise not available to display detail.")
            }
        default:
            // routes defined by platform-specific projects should have been handled earlier
            EmptyView()
        }
    }

    private var aboutView: some View {
        AboutView(shortAppName: shortAppName,
                  websiteURL: websiteAppURL,
                  privacyURL: websitePrivacyURL,
                  termsURL: websiteTermsURL,
                  tutorialURL: websiteAppTutorialURL,
                  copyright: copyright,
                  plea: websitePlea)
        {
            AppIcon(name: "app_icon")
        }
    }
}
