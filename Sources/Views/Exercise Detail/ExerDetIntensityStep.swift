//
//  ExDetIntensityStep.swift
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

struct ExDetIntensityStep: View {
    // MARK: - Parameters

    @Binding var intensityStep: Float
    let units: Units?

    // MARK: - Views

    var body: some View {
        Section {
            FormFloatPad(selection: $intensityStep,
                         precision: Exercise.intensityStepPrecision,
                         upperBound: Exercise.intensityStepRange.upperBound)
            {
                Text("\($0, specifier: specifier)")
                    .font(.title2)
            }
        } header: {
            Text("Intensity Step")
        }
    }

    private var specifier: String {
        let prefix = "%0.1f"
        guard let units else { return prefix }
        return "\(prefix) \(units.abbreviation)"
    }
}

// struct ExDetIntensity_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExDetIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
