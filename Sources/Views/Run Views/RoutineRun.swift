//
//  RoutineRun.swift
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

public struct RoutineRun: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    private var routine: Routine
    @Binding private var isNew: Bool
    @Binding private var startedAt: Date
    private let onStop: (Routine) -> Void

    public init(routine: Routine,
                isNew: Binding<Bool>,
                startedAt: Binding<Date>,
                onStop: @escaping (Routine) -> Void)
    {
        self.routine = routine
        self.onStop = onStop

        _startedAt = startedAt

        _exercises = FetchRequest<Exercise>(entity: Exercise.entity(),
                                            sortDescriptors: Exercise.byUserOrder(),
                                            predicate: routine.exercisePredicate)
        _incomplete = FetchRequest<Exercise>(entity: Exercise.entity(),
                                             sortDescriptors: Exercise.byUserOrder(),
                                             predicate: routine.incompletePredicate)
        _isNew = isNew

        #if os(iOS)
            let uic = UIColor(.accentColor)
            UIPageControl.appearance().currentPageIndicatorTintColor = uic
            UIPageControl.appearance().pageIndicatorTintColor = uic.withAlphaComponent(0.35)
        #endif
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: RoutineRun.self))

    @SceneStorage("routine-run-tab") private var selectedTab: URL = controlTab

    @FetchRequest private var exercises: FetchedResults<Exercise>
    @FetchRequest private var incomplete: FetchedResults<Exercise>

    // MARK: - Views

    public var body: some View {
        TabView(selection: $selectedTab) {
            RoutineControl(routine: routine,
                           onAdd: addAction,
                           onStop: stopAction,
                           onNextIncomplete: nextIncompleteAction,
                           onRemainingCount: { remainingCount },
                           startedAt: startedAt)
                .tag(controlTab)
                .tabItem {
                    Text("Control")
                }

            ForEach(exercises, id: \.self) { exercise in
                ExerciseRun(exercise: exercise,
                            routineStartedAt: startedAt,
                            onNextIncomplete: nextIncompleteAction,
                            hasNextIncomplete: hasNextIncomplete,
                            onEdit: editAction)
                    .tag(exercise.uriRepresentation)
                    .tabItem {
                        Text(exercise.wrappedName)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
//        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
//        #endif
//        #if os(watchOS)
//        .tabViewStyle(.carousel)
//        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                toolbarItem
            }
            #if os(iOS)
                ToolbarItem {
                    Button(action: {
                        editAction(selectedTab)
                    }) {
                        Text("Edit")
                    }
                    .disabled(selectedTab == controlTab)
                }
            #endif
        }

        .onAppear {
            // when starting a routine, select the appropriate tab
            guard isNew else { return }
            isNew = false

            logger.debug("onAppear: starting at the first incomplete exercise, if any")
            nextIncompleteAction(from: nil)
        }

        #if os(iOS)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif

        // advertise running "Start ‘Back & Bicep’ Routine"
        .userActivity(startRoutineActivityType,
                      isActive: hasCompletedAtLeastOneExercise,
                      userActivityUpdate)
    }

    private var toolbarItem: some View {
        Button(action: { Haptics.play(); selectedTab = controlTab }) {
            Image(systemName: "control")
                .foregroundColor(isOnControlPanel ? disabledColor : .primary)
        }
        .disabled(isOnControlPanel)
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        exercises.last?.userOrder ?? 0
    }

    private var isOnControlPanel: Bool {
        selectedTab == controlTab
    }

    private var remainingCount: Int {
        incomplete.count
    }

    private var hasRemaining: Bool {
        remainingCount > 0
    }

    private func hasNextIncomplete() -> Bool {
        remainingCount > 1
    }

    private var completedCount: Int {
        exercises.count - remainingCount
    }

    private var hasCompletedAtLeastOneExercise: Bool {
        completedCount > 0
    }

    // MARK: - Actions/Updates

    private func addAction() {
        logger.debug("\(#function) maxOrder=\(maxOrder)")
        withAnimation {
            Haptics.play()
            let nu = Exercise.create(viewContext, routine: routine, userOrder: maxOrder + 1)
            do {
                try nu.populate(viewContext)
                try viewContext.save()
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
            let uriRep = nu.objectID.uriRepresentation()
            editAction(uriRep)
        }
    }

    private func editAction(_ exerciseURI: URL) {
        logger.debug("\(#function) exerciseURI=\(exerciseURI)")
        Haptics.play()
        // TODO: is a delay actually needed? Try it without.
        DispatchQueue.main.asyncAfter(deadline: .now() + editDelaySeconds) {
            if selectedTab != exerciseURI {
                selectedTab = exerciseURI
            }
            router.path.append(GroutRoute.exerciseDetail(exerciseURI))
        }
    }

    private func stopAction() {
        logger.debug("\(#function)")
        // Haptics.play(.stoppingAction)
        onStop(routine) // parent view will take down the sheet & save context
    }

    // if next incomplete exercise exists, switch to its tab
    private func nextIncompleteAction(from userOrder: Int16?) {
        logger.debug("\(#function) userOrder=\(userOrder ?? -1000)")
        if let nextIncomplete = try? routine.getNextIncomplete(viewContext, from: userOrder) {
            // Haptics.play()
            let nextTab = nextIncomplete.uriRepresentation()
            logger.debug("\(#function) Selecting TAB, from \(selectedTab.suffix ?? "") to \(nextTab.suffix ?? "")")
            selectedTab = nextTab
        } else {
            Haptics.play(.completedAction)
            // logger.debug("\(#function) from \(selectedTab.suffix ?? "") to CONTROL")
            selectedTab = controlTab
        }
    }

    private func userActivityUpdate(_ userActivity: NSUserActivity) {
        logger.debug("\(#function)")
        userActivity.title = "Start ‘\(routine.wrappedName)’ Routine"
        userActivity.userInfo = [
            userActivity_uriRepKey: routine.uriRepresentation,
        ]
        userActivity.isEligibleForPrediction = true
        userActivity.isEligibleForSearch = true
    }
}

struct RoutineRun_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        @State var startedAt: Date = .now.addingTimeInterval(-1000)
        var body: some View {
            NavigationStack {
                RoutineRun(routine: routine,
                           isNew: .constant(true),
                           startedAt: $startedAt,
                           onStop: { _ in })
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = Exercise.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.primarySetting = 4
        e1.secondarySetting = 6
        // e1.units = Units.kilograms.rawValue
        e1.intensityStep = 7.1
        let e2 = Exercise.create(ctx, routine: routine, userOrder: 1)
        e2.name = "Arm Curl"
        return
            TestHolder(routine: routine)
                .environment(\.managedObjectContext, ctx)
    }
}
