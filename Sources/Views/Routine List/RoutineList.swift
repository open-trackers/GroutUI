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

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "RoutineList")

/// Common view shared by watchOS and iOS.
public struct RoutineList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    private let beforeStart: () -> Void

    public init(beforeStart: @escaping () -> Void = {}) {
        self.beforeStart = beforeStart
    }

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
    @SceneStorage("run-last-exercise-completed-at") private var lastExerciseCompletedAt: Date = .distantFuture
    @SceneStorage("updated-archive-ids") private var updatedArchiveIDs: Bool = false

    // timer used to refresh "2d ago, for 16.5m" on each Routine Cell
    @State private var now = Date()
    private let timer = Timer.publish(every: routineSinceUpdateSeconds,
                                      on: .main,
                                      in: .common).autoconnect()

    // support for delete confirmation dialog
    @State private var toBeDeleted: Routine? = nil
    @State private var confirmDelete = false

    // MARK: - Views

    public var body: some View {
        List {
            ForEach(routines, id: \.self) { routine in
                RoutineCell(routine: routine,
                            now: $now,
                            onStart: startAction)
                    .swipeActions(edge: .trailing) {
                        swipeToDelete(routine: routine)
                    }
            }
            .onMove(perform: moveAction)
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
            .confirmationDialog("Are you sure?",
                                isPresented: $confirmDelete,
                                actions: confirmedDelete)
            .onReceive(timer) { _ in
                self.now = Date.now
            }
            .onContinueUserActivity(runRoutineActivityType,
                                    perform: continueUserActivityAction)
            .task(priority: .utility, taskAction)
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
            EntityBackground(.accentColor)
        }
    #endif

    // swipe button to be shown when user has swiped left
    private func swipeToDelete(routine: Routine) -> some View {
        // NOTE that button role is NOT destructive, to prevent item from disappearing before confirmation
        Button(role: .none) {
            toBeDeleted = routine
            confirmDelete = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }

    // confirmation dialog to be shown after user has swiped to delete
    private func confirmedDelete() -> some View {
        withAnimation {
            Button("Delete ‘\(toBeDeleted?.name ?? "")’ routine?",
                   role: .destructive) {
                deleteAction(routine: toBeDeleted)
                confirmDelete = false
                toBeDeleted = nil
            }
        }
    }

    // MARK: - Actions

    private func deleteAction(routine: Routine?) {
        guard let routine else { return }
        viewContext.delete(routine)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        Routine.move(routines, from: source, to: destination)
        do {
            try viewContext.save()
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

        beforeStart() // To force to first tab in iOS app, in case started via shortcut

        do {
            // NOTE: storing startedAt locally (not in routine.lastStartedAt)
            // to ignore mistaken starts.
            startedAt = try routine.start(viewContext, clearData: clearData)
            try viewContext.save()

            isNew = true // forces start at first incomplete exercise
            selectedRoutine = routineURI // displays sheet

        } catch {
            logger.error("\(#function): Start failure \(error.localizedDescription)")
        }
    }

    private func stopAction(_ routine: Routine) {
        logger.notice("\(#function): Stop Routine \(routine.wrappedName)")

        // NOTE: no need to update Routine or ZRoutineRun, as they were both updated in Exercise.logRun.

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

    @Sendable
    private func taskAction() async {
        logger.notice("\(#function) START")

        await PersistenceManager.shared.container.performBackgroundTask { backgroundContext in
            do {
                if !updatedArchiveIDs {
                    updateArchiveIDs(routines: routines.map { $0 })
                    try backgroundContext.save()
                    logger.notice("\(#function): updated archive IDs, where necessary")
                    updatedArchiveIDs = true
                }

                #if os(watchOS)
                    // delete log records older than N days
                    guard let keepSince = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
                    else { throw DataError.missingData(msg: "Clean: could not resolve date one year in past") }
                    logger.notice("\(#function): keepSince=\(keepSince)")
                    try cleanLogRecords(backgroundContext, keepSince: keepSince)
                    try backgroundContext.save()
                #endif

                #if os(iOS)
                    // move log records to archive store
                    try transferToArchive(backgroundContext)
                    try backgroundContext.save()
                #endif
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
        }
        logger.notice("\(#function) END")
    }
}

struct RoutineList_Previews: PreviewProvider {
    struct TestHolder: View {
        var body: some View {
            NavigationStack {
                RoutineList(beforeStart: {})
            }
        }
    }

    static var previews: some View {
        // let container = try! PersistenceManager.getTestContainer()
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        // let ctx = container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder()
            .environment(\.managedObjectContext, ctx)
    }
}
