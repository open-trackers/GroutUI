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
            Button(action: { intensityStep = 1 }) {
                Text("Set to one (1)")
                    .foregroundStyle(tint)
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

//    private func intensityText(_ intensityValue: Float) -> some View {
//        Text(formattedIntensity(intensityValue))
//            // NOTE: needed on watchOS to reduce text size
//            .minimumScaleFactor(0.1)
//            .lineLimit(1)
//        #if os(watchOS)
//            .modify {
//                if #available(iOS 16.1, watchOS 9.1, *) {
//                    $0.fontDesign(.rounded)
//                }
//            }
//        #endif
//    }
//
//    private func formattedIntensity(_ intensity: Float) -> String {
//        if let units {
//            return formatIntensity(intensity, units: units, withUnits: true, isFractional: true)
//        } else {
//            return formatIntensity(intensity, units: .none, withUnits: false, isFractional: true)
//        }
//    }
}

// struct ExDetIntensity_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExDetIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
