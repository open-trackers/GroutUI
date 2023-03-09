//
//  ExerIntensityStepInvert.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExerIntensityStepInvert: View {
    // MARK: - Parameters

    @Binding private var invertedIntensity: Bool
//    @Binding private var intensity: Float
//    @Binding private var intensityStep: Float
//    @Binding private var units: Int16
    private let tint: Color
//    private let isDefault: Bool
//    private let content: () -> Content

    init(invertedIntensity: Binding<Bool>,
//                intensityStep: Binding<Float>,
//                units: Binding<Int16>,
         tint: Color)
//                isDefault: Bool = false)
//                @ViewBuilder content: @escaping () -> Content = { EmptyView() })
    {
//        _intensity = intensity
//        _intensityStep = intensityStep
        _invertedIntensity = invertedIntensity
//        _units = units
        self.tint = tint
//        self.isDefault = isDefault
//        self.content = content
    }

    // MARK: - Locals

//    private let intensityRange: ClosedRange<Float> = 0 ... Exercise.intensityMaxValue
//    private let intensityStepRange: ClosedRange<Float> = 0.1 ... 25
    // private let intensityStep: Float = 0.1

    // MARK: - Views

    var body: some View {
        Section {
            Toggle(isOn: $invertedIntensity) {
                Text("Inverted")
            }
            .tint(tint)
        } header: {
            Text("Advance Direction")
                .foregroundStyle(tint)
        } footer: {
            Text("Example: if inverted with step of 5, advance from 25 to 20")
        }
    }

//        Text(formattedIntensity(intensityValue))
//            // NOTE needed on watchOS to reduce text size
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
//        if let _units = Units(rawValue: units) {
//            return formatIntensity(intensity, units: _units, withUnits: true, isFractional: true)
//        } else {
//            return formatIntensity(intensity, units: .none, withUnits: false, isFractional: true)
//        }
//    }
}

// struct ExerIntensity_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExerIntensity(exercise: exercise, tint: .green)
//        }
//    }
// }
