//
//  ExDetName.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import TextFieldPreset

import GroutLib
import TrackerUI

struct ExDetName: View {
    // MARK: - Parameters

    @Binding var name: String
    let tint: Color

    // MARK: - Views

    var body: some View {
        Section {
            TextFieldPreset($name,
                            prompt: "Enter exercise name",
                            axis: .vertical,
                            presets: exercisePresets)
            {
                Text($0.description)
                // .foregroundStyle(.tint)
            }
            .tint(tint)
        } header: {
            Text("Name")
        }
        #if os(iOS)
        .font(.title3)
        #endif
    }
}

struct ExerciseName_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Beverage"
        @ObservedObject var exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.name = "Lat Pulldown"
        return Form { ExDetName(name: $exercise.wrappedName, tint: .orange) }
    }
}
