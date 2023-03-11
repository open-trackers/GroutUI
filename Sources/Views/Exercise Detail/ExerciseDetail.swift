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
        @State private var selectedTab: Tab = .first

        enum Tab: Int, ControlBarred {
            case name = 1
            case primary = 2
            case secondary = 3
            case sets = 4
            case reps = 5
            case intensity = 6
            case intensityStep = 7
            case intensityUnit = 8
            case intensityInvert = 9

            static var first: Tab = .name
            static var last: Tab = .intensityInvert

            var previous: Tab? {
                Tab(rawValue: rawValue - 1)
            }

            var next: Tab? {
                Tab(rawValue: rawValue + 1)
            }
        }

    #endif

    // MARK: - Views

    public var body: some View {
        platformView
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
                    ExDetSetting(value: $exercise.primarySetting,
                                 tint: exerciseColor,
                                 title: "Primary Setting")
                }
                .tag(Tab.primary)
                Form {
                    ExDetSetting(value: $exercise.secondarySetting,
                                 tint: exerciseColor,
                                 title: "Secondary Setting")
                }
                .tag(Tab.secondary)
                Form {
                    ExDetSets(sets: $exercise.sets,
                              tint: exerciseColor)
                }
                .tag(Tab.sets)
                Form {
                    ExDetReps(repetitions: $exercise.repetitions,
                              tint: exerciseColor)
                }
                .tag(Tab.reps)
                Form {
                    ExDetIntensity(intensity: $exercise.lastIntensity,
                                   intensityStep: exercise.intensityStep,
                                   units: Units(rawValue: exercise.units),
                                   tint: exerciseColor)
                }
                .tag(Tab.intensity)
                Form {
                    ExDetIntensityStep(intensityStep: $exercise.intensityStep,
                                       units: Units(rawValue: exercise.units),
                                       tint: exerciseColor)
                }
                .tag(Tab.intensityStep)
                Form {
                    ExDetIntensityUnits(rawUnits: $exercise.units,
                                        tint: exerciseColor)
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
                               intensityStep: exercise.intensityStep,
                               units: Units(rawValue: exercise.units),
                               tint: exerciseColor)
                ExDetIntensityStep(intensityStep: $exercise.intensityStep,
                                   units: Units(rawValue: exercise.units),
                                   tint: exerciseColor)
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
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(exercise: exercise)
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
