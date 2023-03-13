//
//  ExDetSets.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExDetSets: View {
    // MARK: - Parameters

    @Binding var sets: Int16
    let tint: Color
    var forceFocus: Bool = false

    // MARK: - Locals

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $sets, in: 0 ... 10, step: 1) {
                Text("\(sets)")
            }
            .tint(tint)
            .focused($focusedField)
            .onAppear {
                guard forceFocus else { return }
                focusedField = true
            }
        } header: {
            Text("Set Count")
        }
    }
}

struct ExerciseSets_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ExDetSets(sets: .constant(10),
                      tint: .green)
        }
    }
}
