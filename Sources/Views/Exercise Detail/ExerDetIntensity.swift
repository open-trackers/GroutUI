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

struct ExDetIntensity: View {
    // MARK: - Parameters

    @Binding private var intensity: Float
    private let intensityStep: Float
    private let units: Units?
    private let tint: Color

    init(intensity: Binding<Float>,
         intensityStep: Float,
         units: Units?,
         tint: Color)
    {
        _intensity = intensity
        self.intensityStep = intensityStep
        self.units = units
        self.tint = tint
    }

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $intensity, in: Exercise.intensityRange, step: intensityStep) {
                intensityText(intensity)
            }
            .tint(tint)
            Button(action: { intensity = 0 }) {
                Text("Set to zero (0)")
                    .foregroundStyle(tint)
            }
        } header: {
            Text("Intensity")
        }
    }

    private func intensityText(_ intensityValue: Float) -> some View {
        Text(formattedIntensity(intensityValue))
            // NOTE: needed on watchOS to reduce text size
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        #if os(watchOS)
            .modify {
                if #available(iOS 16.1, watchOS 9.1, *) {
                    $0.fontDesign(.rounded)
                }
            }
        #endif
    }

    private func formattedIntensity(_ intensity: Float) -> String {
        if let units {
            return formatIntensity(intensity, units: units, withUnits: true, isFractional: true)
        } else {
            return formatIntensity(intensity, units: .none, withUnits: false, isFractional: true)
        }
    }
}

// struct ExDetIntensity_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExDetIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
