//
//  ExerDetIntensityStepInvert.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExDetIntensityStepInvert: View {
    // MARK: - Parameters

    @Binding var invertedIntensity: Bool
    let tint: Color

    // MARK: - Views

    var body: some View {
        Section {
            Toggle(isOn: $invertedIntensity) {
                Text("Inverted")
            }
            .tint(tint)
        } header: {
            Text("Advance Direction")
        } footer: {
            Text("Example: if inverted with step of 5, advance from 25 to 20")
        }
    }
}

// struct ExDetIntensityStepInvert_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExDetIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
