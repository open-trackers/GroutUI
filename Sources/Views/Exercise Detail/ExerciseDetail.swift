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
        // NOTE no longer saving the tab in scene storage, because it has been
        // annoying to not start out at the first tab when navigating to detail.
        // @SceneStorage("exercise-detail-tab") private var selectedTab = 0
        @State private var selectedTab: MyTabs = .name

        enum MyTabs: Int, Tabable {
            case name = 1
            case primary = 2
            case secondary = 3
            case sets = 4
            case reps = 5
            case intensity = 6
            case intensityStep = 7
            case intensityUnit = 8
            case intensityInvert = 9

            static var first: MyTabs = .name
            static var last: MyTabs = .intensityInvert

            var description: String {
                "\(rawValue)"
            }

            var previous: MyTabs? {
                MyTabs(rawValue: rawValue - 1)
            }

            var next: MyTabs? {
                MyTabs(rawValue: rawValue + 1)
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
            VStack {
                TabView(selection: $selectedTab) {
                    Form {
                        ExerciseName(exercise: exercise, tint: exerciseColor)
                    }
                    .tag(MyTabs.name)
                    Form {
                        ExerPrimarySettings(exercise: exercise, tint: exerciseColor)
                    }
                    .tag(MyTabs.primary)
                    Form {
                        ExerSecondarySettings(exercise: exercise, tint: exerciseColor)
                    }
                    .tag(MyTabs.secondary)
                    Form {
                        ExerciseSets(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                    }
                    .tag(MyTabs.sets)
                    Form {
                        ExerciseReps(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                    }
                    .tag(MyTabs.reps)
                    Form {
                        ExerIntensity(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                    }
                    .tag(MyTabs.intensity)
                    Form {
                        ExerIntensityStep(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                    }
                    .tag(MyTabs.intensityStep)
                    Form {
                        ExerIntensityUnits(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                    }
                    .tag(MyTabs.intensityUnit)
                    Form {
                        ExerIntensityStepInvert(invertedIntensity: $exercise.invertedIntensity, tint: exerciseColor)
                    }
                    .tag(MyTabs.intensityInvert)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                MyTabControl(selectedTab: $selectedTab, tint: exerciseColor)
            }
            .ignoresSafeArea(.all, edges: [.bottom]) // NOTE allows controls to be at bottom
            .navigationTitle {
                Text(title)
                    .foregroundColor(exerciseColorDarkBg)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = MyTabs.first
                        }
                    }
            }
        }

    #endif

    #if os(iOS)
        private var platformView: some View {
            Form {
                ExerciseName(exercise: exercise, tint: exerciseColor)
                ExerPrimarySettings(exercise: exercise, tint: exerciseColor)
                ExerSecondarySettings(exercise: exercise, tint: exerciseColor)
                ExerciseSets(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                ExerciseReps(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                ExerIntensity(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                ExerIntensityStep(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                ExerIntensityUnits(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                ExerIntensityStepInvert(invertedIntensity: $exercise.invertedIntensity, tint: exerciseColor)
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
