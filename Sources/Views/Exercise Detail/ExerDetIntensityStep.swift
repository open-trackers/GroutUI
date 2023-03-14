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
    let tint: Color
    var forceFocus: Bool = false

    // MARK: - Views

    var body: some View {
        Section {
            ValueStepper(value: $intensityStep,
                         in: Exercise.intensityStepRange,
                         step: 0.1,
                         specifier: specifier,
                         forceFocus: forceFocus)
                .tint(tint)
            HStack {
                FormTextButton("Clear") { intensityStep = 0 }
                #if os(iOS)
                    Spacer()
                    FormTextButton("+1") { intensityStep += 1 }
                    Spacer()
                    FormTextButton("+5") { intensityStep += 5 }
                #endif
                Spacer()
                FormTextButton("+10") { intensityStep += 10 }
            }
            .foregroundStyle(tint)
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
