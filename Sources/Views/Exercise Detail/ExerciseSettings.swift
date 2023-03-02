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
    private let tint: Color

    public init(exercise: Exercise, tint: Color) {
        self.exercise = exercise
        self.tint = tint
    }

    // MARK: - Views

    public var body: some View {
        Section {
            Stepper(value: $exercise.primarySetting, in: settingRange, step: 1) {
                Text("\(exercise.primarySetting)")
            }
            .tint(tint)
        } header: {
            Text("Primary Setting")
                .foregroundStyle(tint)
        }

        Section {
            Stepper(value: $exercise.secondarySetting, in: settingRange, step: 1) {
                Text("\(exercise.secondarySetting)")
            }
            .tint(tint)
        } header: {
            Text("Secondary Setting")
                .foregroundStyle(tint)
        }
    }
}

struct ExerciseSettings_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return Form { ExerciseSettings(exercise: exercise, tint: .blue) }
    }
}
