//
//  ExDetSetting.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExDetSetting: View {
    // MARK: - Parameters

    @Binding var value: Int16
    let tint: Color
    let title: String
    var forceFocus: Bool = false

    // MARK: - Locals

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $value, in: Exercise.settingRange, step: 1) {
                Text("\(value)")
            }
            .tint(tint)
            .focused($focusedField)
            .onAppear {
                guard forceFocus else { return }
                focusedField = true
            }
        } header: {
            Text(title)
        }
    }
}

// struct ExDetSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        let manager = CoreDataStack.getPreviewStack()
//        let ctx = manager.container.viewContext
//        let routine = Routine.create(ctx, userOrder: 0)
//        routine.name = "Beverage"
//        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
//        exercise.name = "Lat Pulldown"
//        return Form { ExDetSetting(exercise: exercise, tint: .blue) }
//    }
// }
