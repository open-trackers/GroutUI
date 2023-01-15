//
//  ExerciseVolume.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

public struct ExerciseVolume: View {
    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise
    private let tint: Color

    public init(exercise: Exercise, tint: Color) {
        self.exercise = exercise
        self.tint = tint
    }

    // MARK: - Views

    public var body: some View {
        Section {
            Stepper(value: $exercise.sets, in: 0 ... 10, step: 1) {
                Text("\(exercise.sets)")
            } onEditingChanged: { _ in
                Haptics.play()
            }
            .tint(tint)
        } header: {
            Text("Set Count")
                .foregroundStyle(tint)
        }

        Section {
            Stepper(value: $exercise.repetitions, in: 0 ... 100, step: 1) {
                Text("\(exercise.repetitions)")
            } onEditingChanged: { _ in
                Haptics.play()
            }
            .tint(tint)
        } header: {
            Text("Repetition Count")
                .foregroundStyle(tint)
        }
    }
}

struct ExerciseVolume_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return Form { ExerciseVolume(exercise: exercise, tint: .green) }
    }
}
