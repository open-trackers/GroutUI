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

    @Binding private var value: Int16
    private let tint: Color
    private let title: String

    init(value: Binding<Int16>,
         tint: Color,
         title: String)
    {
        _value = value
        self.tint = tint
        self.title = title
    }

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $value, in: Exercise.settingRange, step: 1) {
                Text("\(value)")
            }
            .tint(tint)
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
