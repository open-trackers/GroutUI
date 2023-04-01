//
//  RoutineList.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import GroutLib
import TrackerLib
import TrackerUI

extension Routine: Named {}

/// Common view shared by watchOS and iOS.
public struct RoutineList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var manager: CoreDataStack
    @EnvironmentObject private var router: GroutRouter

    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    // MARK: - Parameters

    public init() {}

    // MARK: - Locals

    private let startRoutinePublisher = NotificationCenter.default.publisher(for: .startRoutine)

    private let title = "Gym Routines"

    @AppStorage("routine-is-new-user") private var isNewUser: Bool = true

    // @AppStorage(storageKeyRoutineIsNewUser) private var isNewUser: Bool = true

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: RoutineList.self))

    // NOTE: not stored, to allow resume/restore of started routine
    @State private var isNew = false

    @State private var showGettingStarted = false

    @SceneStorage("routine-run-nav") private var routineRunNavData: Data?
    @SceneStorage("run-selected-routine") private var selectedRoutine: URL? = nil
    @SceneStorage("run-started-at") private var startedAt: Date = .distantFuture

    // MARK: - Views

    public var body: some View {
        CellList(cell: routineCell,
                 addButton: { AddRoutineButton() })
        {
            #if os(watchOS)
                Group {
                    AddRoutineButton()
                    settingsButton
                    aboutButton
                }
                .accentColor(.orange) // NOTE: make the images really orange
                .symbolRenderingMode(.hierarchical)
            #elseif os(iOS)
                EmptyView()
            #endif
        }
        #if os(watchOS)
        // .navigationBarTitleDisplayMode(.large)
        .navigationTitle {
            HStack {
                Text(title)
                    .foregroundStyle(routineColor)
                Spacer() // NOTE: top-level title should be leading-justified
            }
        }
        #elseif os(iOS)
        .navigationTitle(title)
        #endif
        .onAppear(perform: appearAction)
        .gettingStarted(show: $showGettingStarted) {
            GettingStarted()
        }
        .fullScreenCover(item: $selectedRoutine) { url in
            GroutNavStack(navData: $routineRunNavData) {
                VStack {
                    if let routine: Routine = Routine.get(viewContext, forURIRepresentation: url) {
                        RoutineRun(routine: routine,
                                   isNew: $isNew,
                                   startedAt: $startedAt,
                                   onStop: stopAction)
                    } else {
                        Text("Routine not found.")
                    }
                }
            }
        }
        .onReceive(startRoutinePublisher) { payload in
            logger.debug("onReceive: \(startRoutinePublisher.name.rawValue)")
            guard let routineURI = payload.object as? URL else { return }

            // NOTE: not preserving any existing exercise completions; starting anew
            startAction(routineURI)
        }
    }

    private func routineCell(routine: Routine, now: Binding<Date>) -> some View {
        RoutineCell(routine: routine,
                    now: now,
                    onDetail: {
                        detailAction($0)
                    },
                    onShortPress: {
                        startAction($0)
                    })
    }

    #if os(watchOS)
        private var settingsButton: some View {
            Button(action: settingsAction) {
                Label("Settings", systemImage: "gear.circle")
            }
        }

        private var aboutButton: some View {
            Button(action: aboutAction) {
                Label("About \(shortAppName)", systemImage: "info.circle")
            }
        }
    #endif

    #if os(iOS)
        private var rowBackground: some View {
            EntityBackground(.accentColor)
        }
    #endif

    // MARK: - Properties

    private var firstRoutine: Routine? {
        guard let firstRoutine = (try? Routine.getFirst(viewContext))
        else { return nil }
        return firstRoutine
    }

    // MARK: - Actions

    private func appearAction() {
        guard isNewUser else { return }
        isNewUser = false
        logger.debug("\(#function): is new user")
        if firstRoutine == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showGettingStarted = true
            }
        }
    }

    private func detailAction(_ uri: URL) {
        logger.notice("\(#function)")
        Haptics.play()

        router.path.append(GroutRoute.routineDetail(uri))
    }

    // clear existing running routine, if any
    private func clearRun() {
        selectedRoutine = nil
        startedAt = .distantFuture
        router.path.removeAll()
    }

    private func startAction(_ routineURI: URL) {
        clearRun()

        guard let routine: Routine = Routine.get(viewContext, forURIRepresentation: routineURI) else {
            logger.debug("\(#function): couldn't find routine; not starting")
            return
        }

        logger.notice("\(#function): Start Routine \(routine.wrappedName)")

        Haptics.play(.startingAction)

        do {
            // NOTE: storing startedAt locally (not in routine.lastStartedAt)
            // to ignore mistaken starts.
            startedAt = try routine.start(viewContext)
            try viewContext.save()

            isNew = true // forces start at first incomplete exercise
            selectedRoutine = routineURI // displays sheet

        } catch {
            logger.error("\(#function): Start failure \(error.localizedDescription)")
        }
    }

    private func stopAction(_ routine: Routine) {
        logger.notice("\(#function): Stop Routine \(routine.wrappedName)")

        Haptics.play(.stoppingAction)

        // NOTE: no need to update Routine or ZRoutineRun, as they were both updated in Exercise.logRun.

        clearRun()
    }

    #if os(watchOS)
        private func settingsAction() {
            logger.notice("\(#function)")
            Haptics.play()

            router.path.append(GroutRoute.settings)
        }

        private func aboutAction() {
            logger.notice("\(#function)")
            Haptics.play()

            router.path.append(GroutRoute.about)
        }
    #endif
}

struct RoutineList_Previews: PreviewProvider {
    struct TestHolder: View {
        var body: some View {
            NavigationStack {
                RoutineList()
            }
        }
    }

    static var previews: some View {
        // let container = try! PersistenceManager.getTestContainer()
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        // let ctx = container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return TestHolder()
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
        // .accentColor(.green)
    }
}
