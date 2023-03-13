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

    @Binding private var intensity: Float
    private let intensityStep: Float
    private let units: Units?
    private let tint: Color
    private let forceFocus: Bool

    init(intensity: Binding<Float>,
         intensityStep: Float,
         units: Units?,
         tint: Color,
         forceFocus: Bool = false)
    {
        _intensity = intensity
        self.intensityStep = intensityStep
        self.units = units
        self.tint = tint
        self.forceFocus = forceFocus
    }

    // MARK: - Views

    var body: some View {
        Section {
            ValueStepper(value: $intensity,
                         in: Exercise.intensityRange,
                         step: intensityStep,
                         specifier: specifier,
                         forceFocus: forceFocus)
                .tint(tint)
            Button(action: { intensity = 0 }) {
                Text("Set to zero (0)")
                    .foregroundStyle(tint)
            }
        } header: {
            Text("Intensity")
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
