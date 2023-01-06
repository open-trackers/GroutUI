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

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "RoutineList"
)

public struct RoutineList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    public init() {}

    // MARK: - Locals

    @FetchRequest(entity: Routine.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Routine.userOrder, ascending: true)],
                  animation: .default)
    private var routines: FetchedResults<Routine>

    // NOTE not stored, to allow resume/restore of started routine
    @State private var isNew = false

    @SceneStorage("routine-run-nav") private var routineRunNavData: Data?
    @SceneStorage("run-selected-routine") private var selectedRoutine: URL? = nil
    @SceneStorage("run-started-at") private var startedAt: Date = .distantFuture
    @SceneStorage("updated-archive-ids") private var updatedArchiveIDs: Bool = false

    // timer used to refresh "2d ago, for 16.5m" on each Routine Cell
    @State private var now = Date()
    private let timer = Timer.publish(every: routineSinceUpdateSeconds,
                                      on: .main,
                                      in: .common).autoconnect()

    // MARK: - Views

    public var body: some View {
        List {
            ForEach(routines, id: \.self) { routine in
                RoutineCell(routine: routine,
                            now: $now,
                            onStart: startAction)
            }
            .onMove(perform: moveAction)
            .onDelete(perform: deleteAction)
            #if os(watchOS)
                .listItemTint(routineListItemTint)
            #elseif os(iOS)
                .listRowBackground(rowBackground)
            #endif

            #if os(watchOS)
                Group {
                    addButton
                    settingsButton
                    aboutButton
                }
                .font(.title3)
                .tint(routineColor)
                .foregroundStyle(.tint)
            #endif
        }
        .navigationTitle("Routines")
        #if os(iOS)
            .toolbar {
                ToolbarItem {
                    AddRoutineButton {
                        Text("Add")
                    }
                }
            }
        #endif
            .fullScreenCover(item: $selectedRoutine) { url in
                NavStack(name: "routineRun", navData: $routineRunNavData) {
                    VStack {
                        if let routine = Routine.get(viewContext, forURIRepresentation: url) {
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
            .onReceive(timer) { _ in
                self.now = Date.now
            }
            .onContinueUserActivity(runRoutineActivityType,
                                    perform: continueUserActivityAction)
            .onAppear {
                // TODO: move to .task?
                guard !updatedArchiveIDs else { return }
                updateArchiveIDs()
                updatedArchiveIDs = true
            }
            .task {
                logger.notice(">>>>>>>>>>>>>>>>>>>>>> task")
                #if os(watchOS)
                    // delete log records older than N days
                    cleanLogRecords(viewContext)
                #elseif os(iOS)

                #endif
            }
    }

    #if os(watchOS)
        private var addButton: some View {
            AddRoutineButton {
                Label("Add Routine", systemImage: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
            }
        }

        private var settingsButton: some View {
            Button(action: settingsAction) {
                Label("Settings", systemImage: "gear.circle")
                    .symbolRenderingMode(.hierarchical)
            }
        }

        private var aboutButton: some View {
            Button(action: aboutAction) {
                Label(title: { Text("About") }, icon: {
                    AppIcon(name: "grt_icon")
                        .frame(width: 24, height: 24)
                })
            }
        }
    #endif

    #if os(iOS)
        private var rowBackground: some View {
            LinearGradient(gradient: .init(colors: [
                .accentColor.opacity(0.1),
                .accentColor.opacity(0.2),
            ]),
            startPoint: .topLeading,
            endPoint: .bottom)
        }
    #endif

    // MARK: - Actions

    private func deleteAction(offsets: IndexSet) {
        offsets.map { routines[$0] }.forEach(viewContext.delete)
        do {
            try PersistenceManager.shared.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        Routine.move(routines, from: source, to: destination)
        do {
            try PersistenceManager.shared.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func startAction(_ routineURI: URL, clearData: Bool) {
        guard let routine = Routine.get(viewContext, forURIRepresentation: routineURI) else {
            logger.debug("\(#function): couldn't find routine; not starting")
            return
        }

        logger.notice("\(#function): Start Routine \(routine.wrappedName)")

        do {
            // NOTE: storing startedAt locally (not in routine.lastStartedAt)
            // to ignore mistaken starts.
            startedAt = try routine.start(viewContext, clearData: clearData)
            try PersistenceManager.shared.save()

            isNew = true // forces start at first incomplete exercise
            selectedRoutine = routineURI // displays sheet

        } catch let error as NSError {
            logger.error("\(#function): Start failure \(nserror.localizedDescription)")
        }
    }

    private func stopAction(_ routine: Routine) {
        logger.notice("\(#function): Stop Routine \(routine.wrappedName)")
        do {
            if try routine.stop(viewContext, startedAt: startedAt) {
                try PersistenceManager.shared.save()
            } else {
                logger.debug("\(#function): not recorded, probably because no exercises completed")
            }
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
        startedAt = Date.distantFuture
        selectedRoutine = nil // closes sheet
    }

    private func continueUserActivityAction(_ userActivity: NSUserActivity) {
        guard let routineURI = userActivity.userInfo?[userActivity_uriRepKey] as? URL,
              let routine = NSManagedObject.get(viewContext, forURIRepresentation: routineURI) as? Routine
        else {
            logger.notice("\(#function): unable to continue User Activity")
            return
        }

        logger.notice("\(#function): continueUserActivityAction on routine=\(routine.wrappedName)")

        // NOTE: not clearing data, so completed exercises are preserved
        startAction(routineURI, clearData: true)
    }

    #if os(watchOS)
        private func settingsAction() {
            router.path.append(MyRoutes.settings)
        }

        private func aboutAction() {
            router.path.append(MyRoutes.about)
        }
    #endif

    // MARK: - Helpers

    /// Ensure all the records have archiveIDs
    private func updateArchiveIDs() {
        for routine in routines {
            if let _ = routine.archiveID { continue }
            routine.archiveID = UUID()
            logger.notice("\(#function): added archiveID to \(routine.wrappedName)")
            guard let exercises = routine.exercises?.allObjects as? [Exercise] else { continue }
            for exercise in exercises {
                if let _ = exercise.archiveID { continue }
                exercise.archiveID = UUID()
                logger.notice("\(#function): added archiveID to \(exercise.wrappedName)")
            }
        }
        do {
            try PersistenceManager.shared.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
        logger.notice("updated archive IDs, where necessary")
    }
}

// TODO: four copies of each routine showing up; should be one!
struct RoutineList_Previews: PreviewProvider {
    struct TestHolder: View {
        var body: some View {
            NavigationStack {
                RoutineList()
            }
        }
    }

    static var previews: some View {
        let ctx = PersistenceManager.preview.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder()
            .environment(\.managedObjectContext, ctx)
    }
}
