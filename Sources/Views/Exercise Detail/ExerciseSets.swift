//
//  ExerciseSets.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExerciseSets: View {
    // MARK: - Parameters

    @Binding private var sets: Int16
    @Binding private var repetitions: Int16
    private let tint: Color
    private let isDefault: Bool

    init(sets: Binding<Int16>,
         repetitions: Binding<Int16>,
         tint: Color,
         isDefault: Bool = false)
    {
        // self.exercise = exercise
        _sets = sets
        _repetitions = repetitions
        self.tint = tint
        self.isDefault = isDefault
    }

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $sets, in: 0 ... 10, step: 1) {
                Text("\(sets)")
            }
            .tint(tint)
        } header: {
            Text("Set Count")
        }

//        Section {
//            Stepper(value: $repetitions, in: 0 ... 100, step: 1) {
//                Text("\(repetitions)")
//            }
//            .tint(tint)
//        } header: {
//            Text("Repetition Count")
//                .foregroundStyle(tint)
//        }
    }
}

struct ExerciseSets_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ExerciseSets(sets: .constant(10),
                         repetitions: .constant(13),
                         tint: .green)
        }
    }
}
