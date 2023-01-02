//
//  ExerciseSettings.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

public struct ExerciseSettings: View {
    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise

    public init(exercise: Exercise) {
        self.exercise = exercise
    }

    // MARK: - Views

    public var body: some View {
        Section("Primary Setting") {
            Stepper(value: $exercise.primarySetting, in: settingRange, step: 1) {
                Text("\(exercise.primarySetting)")
            }
            .tint(exerciseColor)
        }

        Section("Secondary Setting") {
            Stepper(value: $exercise.secondarySetting, in: settingRange, step: 1) {
                Text("\(exercise.secondarySetting)")
            }
            .tint(exerciseColor)
        }
    }
}

struct ExerciseSettings_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceManager.preview.container.viewContext
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return Form { ExerciseSettings(exercise: exercise) }
    }
}
