//
//  ExerciseDetail.swift
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

public struct ExerciseDetail: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise

    public init(exercise: Exercise) {
        self.exercise = exercise
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: ExerciseDetail.self))

    #if os(watchOS)
        // NOTE: no longer saving the tab in scene storage, because it has been
        // annoying to not start out at the first tab when navigating to detail.
        // @SceneStorage("exercise-detail-tab") private var selectedTab = 0
        @State private var selectedTab: Tab = .name

        enum Tab: Int, CaseIterable {
            case name = 1
            case routine = 2
            case primary = 3
            case secondary = 4
            case sets = 5
            case reps = 6
            case intensity = 7
            case intensityStep = 8
            case intensityUnit = 9
            case intensityInvert = 10
        }
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
            .accentColor(exerciseColor)
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: onDisappearAction)
    }

    #if os(watchOS)
        private var platformView: some View {
            ControlBarTabView(selection: $selectedTab, tint: exerciseColor, title: title) {
                Form {
                    ExDetName(name: $exercise.wrappedName,
                              tint: exerciseColor)
                }
                .tag(Tab.name)
                Form {
                    if let routine = exercise.routine {
                        ExDetRoutine(routine: routine, onSelect: selectRoutineAction)
                    } else {
                        Text("Routine not available")
                    }
                }
                .tag(Tab.routine)
                Form {
                    ExDetSetting(value: $exercise.primarySetting,
                                 tint: exerciseColor,
                                 title: "Primary Setting",
                                 forceFocus: true)
                }
                .tag(Tab.primary)
                Form {
                    ExDetSetting(value: $exercise.secondarySetting,
                                 tint: exerciseColor,
                                 title: "Secondary Setting",
                                 forceFocus: true)
                }
                .tag(Tab.secondary)
                Form {
                    ExDetSets(sets: $exercise.sets,
                              tint: exerciseColor,
                              forceFocus: true)
                }
                .tag(Tab.sets)
                Form {
                    ExDetReps(repetitions: $exercise.repetitions,
                              tint: exerciseColor,
                              forceFocus: true)
                }
                .tag(Tab.reps)
                Form {
                    ExDetIntensity(intensity: $exercise.lastIntensity,
                                   units: Units(rawValue: exercise.units))
                }
                .tag(Tab.intensity)
                Form {
                    ExDetIntensityStep(intensityStep: $exercise.intensityStep,
                                       units: Units(rawValue: exercise.units))
                }
                .tag(Tab.intensityStep)
                Form {
                    ExDetIntensityUnits(rawUnits: $exercise.units,
                                        tint: exerciseColor,
                                        forceFocus: true)
                }
                .tag(Tab.intensityUnit)
                Form {
                    ExDetIntensityStepInvert(invertedIntensity: $exercise.invertedIntensity,
                                             tint: exerciseColor)
                }
                .tag(Tab.intensityInvert)
            }
        }

    #endif

    #if os(iOS)
        private var platformView: some View {
            Form {
                ExDetName(name: $exercise.wrappedName,
                          tint: exerciseColor)
                if let routine = exercise.routine {
                    ExDetRoutine(routine: routine, onSelect: selectRoutineAction)
                }
                ExDetSetting(value: $exercise.primarySetting,
                             tint: exerciseColor,
                             title: "Primary Setting")
                ExDetSetting(value: $exercise.secondarySetting,
                             tint: exerciseColor,
                             title: "Secondary Setting")
                ExDetSets(sets: $exercise.sets,
                          tint: exerciseColor)
                ExDetReps(repetitions: $exercise.repetitions,
                          tint: exerciseColor)
                ExDetIntensity(intensity: $exercise.lastIntensity,
                               units: Units(rawValue: exercise.units))
                ExDetIntensityStep(intensityStep: $exercise.intensityStep,
                                   units: Units(rawValue: exercise.units))
                ExDetIntensityUnits(rawUnits: $exercise.units,
                                    tint: exerciseColor)
                ExDetIntensityStepInvert(invertedIntensity: $exercise.invertedIntensity,
                                         tint: exerciseColor)
            }
            .navigationTitle(title)
        }
    #endif

    // MARK: - Properties

    private var exerciseColor: Color {
        colorScheme == .light ? exerciseColorLiteBg : exerciseColorDarkBg
    }

    private var title: String {
        "Exercise"
    }

    // MARK: - Actions

    // if user selects a new routine, the exercise should no longer be in routine's list of exercises
    private func selectRoutineAction(nuRoutineArchiveID: UUID?) {
        guard let nuRoutineArchiveID,
              nuRoutineArchiveID != exercise.routine?.archiveID else { return }
        do {
            guard let nu = try Routine.get(viewContext, archiveID: nuRoutineArchiveID)
            else { return }
            try exercise.move(viewContext, to: nu)
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func onDisappearAction() {
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

struct ExerciseDetail_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        var body: some View {
            NavigationStack {
                ExerciseDetail(exercise: exercise)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine1 = Routine.create(ctx, userOrder: 0)
        routine1.name = "Back & Bicep"
        let routine2 = Routine.create(ctx, userOrder: 1)
        routine2.name = "Check & Shoulders"
        let exercise = Exercise.create(ctx, routine: routine1, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return TestHolder(exercise: exercise)
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
