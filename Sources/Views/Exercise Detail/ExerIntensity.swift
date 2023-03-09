//
//  ExerIntensity.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExerIntensity: View {
    // MARK: - Parameters

    @Binding private var intensity: Float
    @Binding private var intensityStep: Float
    @Binding private var units: Int16
    private let tint: Color
    private let isDefault: Bool
//    private let content: () -> Content

    init(intensity: Binding<Float>,
         intensityStep: Binding<Float>,
         units: Binding<Int16>,
         tint: Color,
         isDefault: Bool = false)
//                @ViewBuilder content: @escaping () -> Content = { EmptyView() })
    {
        _intensity = intensity
        _intensityStep = intensityStep
        _units = units
        self.tint = tint
        self.isDefault = isDefault
//        self.content = content
    }

    // MARK: - Locals

    private let intensityRange: ClosedRange<Float> = 0 ... Exercise.intensityMaxValue
    private let intensityStepRange: ClosedRange<Float> = 0.1 ... 25
    // private let intensityStep: Float = 0.1

    // MARK: - Views

    var body: some View {
        Section {
            Stepper(value: $intensity, in: intensityRange, step: intensityStep) {
                intensityText(intensity)
            }
            .tint(tint)
            Button(action: { intensity = 0 }) {
                Text("Set to zero (0)")
                    .foregroundStyle(tint)
            }
        } header: {
            Text("Intensity")
                .foregroundStyle(tint)
        }

//        Section {
//            Stepper(value: $intensityStep, in: intensityStepRange, step: 0.1) {
//                intensityText(intensityStep)
//            }
//            .tint(tint)
//            Button(action: { intensityStep = 1 }) {
//                Text("Set to one (1)")
//                    .foregroundStyle(tint)
//            }
//        } header: {
//            Text("Intensity Step")
//                .foregroundStyle(tint)
//        }
//
//        Section {
//            Picker(selection: $units) {
//                ForEach(Units.allCases, id: \.self) { unit in
//                    Text(unit.formattedDescription)
//                        .font(.title3)
//                        .tag(unit.rawValue)
//                }
//            } label: {
//                EmptyView()
//            }
//            #if os(watchOS)
//            .pickerStyle(.wheel)
//            #endif
//            .onChange(of: units) {
//                units = $0
//            }
//        } header: {
//            Text("Intensity Units")
//                .foregroundStyle(tint)
//        }

//        content()
//        Section {
//            Toggle(isOn: $exercise.invertedIntensity) {
//                Text("Inverted")
//            }
//            .tint(tint)
//        } header: {
//            Text("Advance Direction")
//                .foregroundStyle(tint)
//        } footer: {
//            Text("Example: if inverted with step of 5, advance from 25 to 20")
//        }
    }

    private func intensityText(_ intensityValue: Float) -> some View {
        Text(formattedIntensity(intensityValue))
            // NOTE needed on watchOS to reduce text size
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
        if let _units = Units(rawValue: units) {
            return formatIntensity(intensity, units: _units, withUnits: true, isFractional: true)
        } else {
            return formatIntensity(intensity, units: .none, withUnits: false, isFractional: true)
        }
    }
}

// struct ExerIntensity_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExerIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
