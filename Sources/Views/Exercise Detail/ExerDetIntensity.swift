//
//  ExDetIntensity.swift
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

struct ExDetIntensity: View {
    // MARK: - Parameters

    @Binding var intensity: Float
    var intensityStep: Float = 0.1
    let units: Units?
    let tint: Color
    var forceFocus: Bool = false

    // MARK: - Views

    var body: some View {
        Section {
            ValueStepper(value: $intensity,
                         in: Exercise.intensityRange,
                         step: intensityStep,
                         specifier: specifier,
                         forceFocus: forceFocus)
                .tint(tint)
            HStack {
                FormTextButton("Clear") { intensity = 0 }
                #if os(iOS)
                    Spacer()
                    FormTextButton("+10") { intensity += 10 }
                    Spacer()
                    FormTextButton("+50") { intensity += 50 }
                #endif
                Spacer()
                FormTextButton("+100") { intensity += 100 }
            }
            .foregroundStyle(tint)
        } header: {
            Text("Intensity")
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
