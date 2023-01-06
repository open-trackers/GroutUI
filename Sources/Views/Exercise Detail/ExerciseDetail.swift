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

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ExerciseDetail"
)

public struct ExerciseDetail: View {
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    private var exercise: Exercise

    public init(exercise: Exercise) {
        self.exercise = exercise
    }

    // MARK: - Locals

    #if os(watchOS)
        @SceneStorage("exercise-detail-tab") private var tabSelected = 1
    #endif

    // MARK: - Views

    public var body: some View {
        content
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: onDisappearAction)
    }

    private var content: some View {
        #if os(watchOS)

            TabView(selection: $tabSelected) {
                Form {
                    ExerciseName(exercise: exercise)
                    ExerciseSettings(exercise: exercise)
                }
                .tag(1)
                Form {
                    ExerciseVolume(exercise: exercise)
                }
                .tag(2)
                Form {
                    ExerciseIntensity(exercise: exercise)
                }
                .tag(3)
            }
            .tabViewStyle(.page)
            .navigationTitle {
                Text(title)
                    .foregroundColor(exerciseColor)
            }

        #elseif os(iOS)
            Form {
                ExerciseName(exercise: exercise)
                ExerciseSettings(exercise: exercise)
                ExerciseVolume(exercise: exercise)
                ExerciseIntensity(exercise: exercise)
            }
            .navigationTitle("Exercise")
        #endif
    }

    private var title: String {
        "Exercise"
    }

    // MARK: - Actions

    private func onDisappearAction() {
        do {
            try PersistenceManager.shared.save()
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
        let ctx = PersistenceManager.preview.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(exercise: exercise)
            .environment(\.managedObjectContext, ctx)
    }
}
