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

    @Binding var repetitions: Int16
    let tint: Color
    var forceFocus: Bool = false

    // MARK: - Locals

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $repetitions, in: 0 ... 100, step: 1) {
                Text("\(repetitions)")
            }
            .tint(tint)
            .focused($focusedField)
            .onAppear {
                guard forceFocus else { return }
                focusedField = true
            }
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
