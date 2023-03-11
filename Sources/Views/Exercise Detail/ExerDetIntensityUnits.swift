//
//  ExDetIntensityUnits.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExDetIntensityUnits: View {
    // MARK: - Parameters

    @Binding private var rawUnits: Int16
    private let tint: Color

    init(rawUnits: Binding<Int16>,
         tint: Color)
    {
        _rawUnits = rawUnits
        self.tint = tint
    }

    // MARK: - Views

    var body: some View {
        Section {
            Picker(selection: $rawUnits) {
                ForEach(Units.allCases, id: \.self) { unit in
                    Text(unit.formattedDescription)
                        .font(.title3)
                        .tag(unit.rawValue)
                }
            } label: {
                EmptyView()
            }
            #if os(watchOS)
            .pickerStyle(.wheel)
            #endif
            .onChange(of: rawUnits) {
                rawUnits = $0
            }
        } header: {
            Text("Intensity Units")
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
        if let _units = Units(rawValue: rawUnits) {
            return formatIntensity(intensity, units: _units, withUnits: true, isFractional: true)
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
