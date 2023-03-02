//
//  ExerciseName.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib
import TrackerUI

public struct ExerciseName: View {
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
            TextFieldWithPresets($exercise.wrappedName,
                                 prompt: "Enter exercise name",
                                 presets: exercisePresets) { _, _ in
                // nothing to set other than the name
            } label: {
                Text($0)
                    .foregroundStyle(.tint)
            }
        } header: {
            Text("Name")
                .foregroundStyle(tint)
        }
    }
}

struct ExerciseName_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return Form { ExerciseName(exercise: exercise, tint: .orange) }
    }
}
