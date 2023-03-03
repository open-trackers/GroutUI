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

private let storageKeyRoutineIsNewUser = "routine-is-new-user"

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

    private let onShortcut: () -> Void

    public init(onShortcut: @escaping () -> Void = {}) {
        self.onShortcut = onShortcut
    }

    // MARK: - Locals

    @AppStorage(storageKeyRoutineIsNewUser) private var isNewUser: Bool = true

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: RoutineList.self))

    @State private var showNewUser = false

//    @FetchRequest(entity: Routine.entity(),
//                  sortDescriptors: [NSSortDescriptor(keyPath: \Routine.userOrder, ascending: true)],
//                  animation: .default)
//    private var routines: FetchedResults<Routine>
//
    // NOTE not stored, to allow resume/restore of started routine
    @State private var isNew = false
//
//    @SceneStorage("routine-run-nav") private var routineRunNavData: Data?
    @SceneStorage("run-selected-routine") private var selectedRoutine: URL? = nil
    @SceneStorage("run-started-at") private var startedAt: Date = .distantFuture
//    @SceneStorage("run-last-exercise-completed-at") private var lastExerciseCompletedAt: Date = .distantFuture
    @SceneStorage("updated-archive-ids") private var updatedArchiveIDs: Bool = false
    @SceneStorage("updated-created-ats") private var updatedCreatedAts: Bool = false
//
//    // timer used to refresh "2d ago, for 16.5m" on each Routine Cell
//    @State private var now = Date()
//    private let timer = Timer.publish(every: routineSinceUpdateSeconds,
//                                      on: .main,
//                                      in: .common).autoconnect()
//
//    // support for delete confirmation dialog
//    @State private var toBeDeleted: Routine? = nil
//    @State private var confirmDelete = false

    // MARK: - Views

    public var body: some View {
        CellList(cell: routineCell,
                 addButton: { AddRoutineButton() }) {
            #if os(watchOS)
                watchButtons
            #elseif os(iOS)
                EmptyView()
            #endif
        }
        #if os(watchOS)
        // .navigationBarTitleDisplayMode(.large)
        .navigationTitle {
            NavTitle(title)
        }
        #elseif os(iOS)
        // .navigationBarTitleDisplayMode(.inline) // reduces the space allocated
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                CalorieTitle()
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundStyle(.tint)
//            }
//        }
        .navigationTitle(title)
        #endif
        .onAppear(perform: appearAction)
        .sheet(isPresented: $showNewUser) {
            NavigationStack {
                if let appSetting = try? AppSetting.getOrCreate(viewContext) {
                    GettingStarted(appSetting: appSetting, show: $showNewUser)
                } else {
                    Text("Unable to retrieve settings")
                }
            }
        }
        .onContinueUserActivity(runRoutineActivityType,
                                perform: continueUserActivityAction)
        .task(priority: .utility, taskAction)
//        List {
//            ForEach(routines, id: \.self) { routine in
//                RoutineCell(routine: routine,
//                            now: $now,
//                            onStart: startAction)
//                    .swipeActions(edge: .trailing) {
//                        swipeToDelete(routine: routine)
//                    }
//            }
//            .onMove(perform: moveAction)
//            #if os(watchOS)
//                .listItemTint(routineListItemTint)
//            #elseif os(iOS)
//                .listRowBackground(rowBackground)
//            #endif
//
//            #if os(watchOS)
//                Group {
//                    addButton
//                    settingsButton
//                    aboutButton
//                }
//                .font(.title3)
//                .tint(routineColor)
//                .foregroundStyle(.tint)
//            #endif
//        }
//        .navigationTitle("Routines")
//        #if os(iOS)
//            .toolbar {
//                ToolbarItem {
//                    AddRoutineButton {
//                        Text("Add")
//                    }
//                }
//            }
//        #endif
//            .fullScreenCover(item: $selectedRoutine) { url in
//                NavStack(navData: $routineRunNavData) {
//                    VStack {
//                        if let routine = Routine.get(viewContext, forURIRepresentation: url) {
//                            RoutineRun(routine: routine,
//                                       isNew: $isNew,
//                                       startedAt: $startedAt,
//                                       onStop: stopAction)
//                        } else {
//                            Text("Routine not found.")
//                        }
//                    }
//                }
//            }
//            .confirmationDialog("Are you sure?",
//                                isPresented: $confirmDelete,
//                                actions: confirmedDelete)
//            .onReceive(timer) { _ in
//                self.now = Date.now
//            }
//            .onContinueUserActivity(runRoutineActivityType,
//                                    perform: continueUserActivityAction)
//            .task(priority: .utility, taskAction)
    }

    private func routineCell(routine: Routine, now: Binding<Date>) -> some View {
        RoutineCell(routine: routine,
                    now: now,
                    onDetail: {
                        detailAction($0)
                    },
                    onShortPress: {
                        startAction($0, clearData: $1)
                    })
    }

//    #if os(watchOS)
//        private var addButton: some View {
//            AddRoutineButton {
//                Label("Add Routine", systemImage: "plus.circle.fill")
//                    .symbolRenderingMode(.hierarchical)
//            }
//        }
//
//        private var settingsButton: some View {
//            Button(action: settingsAction) {
//                Label("Settings", systemImage: "gear.circle")
//                    .symbolRenderingMode(.hierarchical)
//            }
//        }
//
//        private var aboutButton: some View {
//            Button(action: aboutAction) {
//                Label(title: { Text("About") }, icon: {
//                    AppIcon(name: "grt_icon")
//                        .frame(width: 24, height: 24)
//                })
//            }
//        }
//    #endif

    #if os(watchOS)
        @ViewBuilder
        private var watchButtons: some View {
            Group {
                addButton
                settingsButton
                aboutButton
            }
            .font(.title3)
            .tint(routineColor)
            .foregroundStyle(.tint)
            .symbolRenderingMode(.hierarchical)
        }

        private var addButton: some View {
            AddRoutineButton()
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

//    // swipe button to be shown when user has swiped left
//    private func swipeToDelete(routine: Routine) -> some View {
//        // NOTE that button role is NOT destructive, to prevent item from disappearing before confirmation
//        Button(role: .none) {
//            toBeDeleted = routine
//            confirmDelete = true
//        } label: {
//            Label("Delete", systemImage: "trash")
//        }
//        .tint(.red)
//    }
//
//    // confirmation dialog to be shown after user has swiped to delete
//    private func confirmedDelete() -> some View {
//        withAnimation {
//            Button("Delete ‘\(toBeDeleted?.name ?? "")’",
//                   role: .destructive) {
//                deleteAction(routine: toBeDeleted)
//                confirmDelete = false
//                toBeDeleted = nil
//            }
//        }
//    }

    // MARK: - Properties

    private var title: String {
        "Routines"
    }

    // MARK: - Actions

    private func appearAction() {
        // if a new user, prompt for target calories and ask if they'd like to create the standard categories
        if isNewUser {
            isNewUser = false
            showNewUser = true
        }
    }

    private func detailAction(_ uri: URL) {
        logger.notice("\(#function)")
        Haptics.play()

        router.path.append(GroutRoute.routineDetail(uri))
    }

//    private func deleteAction(routine: Routine?) {
//        guard let routine else { return }
//        viewContext.delete(routine)
//        do {
//            try viewContext.save()
//        } catch {
//            logger.error("\(#function): \(error.localizedDescription)")
//        }
//    }

//    private func moveAction(from source: IndexSet, to destination: Int) {
//        Routine.move(routines, from: source, to: destination)
//        do {
//            try viewContext.save()
//        } catch {
//            logger.error("\(#function): \(error.localizedDescription)")
//        }
//    }

    private func startAction(_ routineURI: URL, clearData: Bool) {
        guard let routine: Routine = Routine.get(viewContext, forURIRepresentation: routineURI) else {
            logger.debug("\(#function): couldn't find routine; not starting")
            return
        }

        logger.notice("\(#function): Start Routine \(routine.wrappedName)")

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

    // MARK: - Background Task

    @Sendable
    private func taskAction() async {
        logger.notice("\(#function) START")

        await manager.container.performBackgroundTask { backgroundContext in
            do {
                if !updatedArchiveIDs {
                    try updateArchiveIDs(backgroundContext)
                    try backgroundContext.save()
                    logger.notice("\(#function): updated archive IDs, where necessary")
                    updatedArchiveIDs = true
                    try backgroundContext.save()
                }

                if !updatedCreatedAts {
                    try updateCreatedAts(backgroundContext)
                    try backgroundContext.save()
                    logger.notice("\(#function): updated createdAts, where necessary")
                    updatedArchiveIDs = true
                    try backgroundContext.save()
                }

                #if os(watchOS)
                    // delete log records older than N days
                    guard let keepSince = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
                    else { throw TrackerError.missingData(msg: "Clean: could not resolve date one year in past") }
                    logger.notice("\(#function): keepSince=\(keepSince)")
                    try cleanLogRecords(backgroundContext, keepSince: keepSince)
                    try backgroundContext.save()
                #endif

                #if os(iOS)
                    guard let mainStore = manager.getMainStore(backgroundContext),
                          let archiveStore = manager.getArchiveStore(backgroundContext)
                    else {
                        logger.error("\(#function): unable to acquire configuration to transfer log records.")
                        return
                    }

                    // move log records to archive store
                    try transferToArchive(backgroundContext,
                                          mainStore: mainStore,
                                          archiveStore: archiveStore)
                    try backgroundContext.save()
                #endif
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
        }
        logger.notice("\(#function) END")
    }

    // MARK: - User Activity

    private func continueUserActivityAction(_ userActivity: NSUserActivity) {
        guard let routineURI = userActivity.userInfo?[userActivity_uriRepKey] as? URL,
              let routine = NSManagedObject.get(viewContext, forURIRepresentation: routineURI) as? Routine
        else {
            logger.notice("\(#function): unable to continue User Activity")
            return
        }

        logger.notice("\(#function): continueUserActivityAction on routine=\(routine.wrappedName)")

        onShortcut() // To force to first tab in iOS app, in case started via shortcut

        // NOTE: not clearing data, so completed exercises are preserved
        startAction(routineURI, clearData: true)
    }
}

struct RoutineList_Previews: PreviewProvider {
    struct TestHolder: View {
        var body: some View {
            NavigationStack {
                RoutineList(onShortcut: {})
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
        exercise.routine = routine
        return TestHolder()
            .environment(\.managedObjectContext, ctx)
    }
}
