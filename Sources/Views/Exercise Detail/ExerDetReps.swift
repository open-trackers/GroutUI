//
//  ExDetReps.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExDetReps: View {
    // MARK: - Parameters

    @Binding private var repetitions: Int16
    private let tint: Color

    init(repetitions: Binding<Int16>,
         tint: Color)
    {
        _repetitions = repetitions
        self.tint = tint
    }

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $repetitions, in: 0 ... 100, step: 1) {
                Text("\(repetitions)")
            }
            .tint(tint)
        } header: {
            Text("Repetition Count")
        }
    }
}

struct ExerciseReps_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ExDetReps(repetitions: .constant(13),
                      tint: .green)
        }
    }
}
