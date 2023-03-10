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
        @State private var selectedTab: Int = 0
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: onDisappearAction)
    }

    #if os(watchOS)

        private func myTab(_ tagNo: Int,
                           @ViewBuilder content: () -> some View) -> some View
        {
            VStack {
                Form {
                    content()
                }
                .frame(maxHeight: .infinity)

                Spacer(minLength: 10) // needed to place button at bottom

                HStack {
                    Button(action: previousTabAction) {
                        Image(systemName: "arrow.left.circle.fill")
                    }
                    Spacer()
                    Button(action: nextTabAction) {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                }
                .imageScale(.large)
                .padding(.horizontal, 20)
                .buttonStyle(.plain)
                .foregroundStyle(exerciseColor)
                .padding(.bottom)
            }
            .tag(tagNo)
            // .border(.primary.opacity(0.2))
            .ignoresSafeArea(.all, edges: [.bottom])
        }

        private var platformView: some View {
            TabView(selection: $selectedTab) {
                myTab(0) {
                    ExerciseName(exercise: exercise, tint: exerciseColor)
                }
                myTab(1) {
                    ExerPrimarySettings(exercise: exercise, tint: exerciseColor)
                }
                myTab(2) {
                    ExerSecondarySettings(exercise: exercise, tint: exerciseColor)
                }
                myTab(3) {
                    ExerciseSets(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                }
                myTab(4) {
                    ExerciseReps(sets: $exercise.sets, repetitions: $exercise.repetitions, tint: exerciseColor)
                }
                myTab(5) {
                    ExerIntensity(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                }
                myTab(6) {
                    ExerIntensityStep(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                }
                myTab(7) {
                    ExerIntensityUnits(intensity: $exercise.lastIntensity, intensityStep: $exercise.intensityStep, units: $exercise.units, tint: exerciseColor)
                }
                myTab(8) {
                    ExerIntensityStepInvert(invertedIntensity: $exercise.invertedIntensity, tint: exerciseColor)
                }
            }
            .tabViewStyle(.page)
            .navigationTitle {
                Text(title)
                    .foregroundColor(exerciseColorDarkBg)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
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

    #if os(watchOS)

        private func previousTabAction() {
            if selectedTab == 0 { selectedTab = 8 } else {
                selectedTab -= 1
            }
        }

        private func nextTabAction() {
            if selectedTab == 8 { selectedTab = 0 } else {
                selectedTab += 1
            }
        }
    #endif

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
