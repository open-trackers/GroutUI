//
//  ExerDetIntensityUnits.swift
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

    @Binding var rawUnits: Int16
    let tint: Color
    var forceFocus: Bool = false

    // MARK: - Locals

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

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
            .focused($focusedField)
            .onAppear {
                guard forceFocus else { return }
                focusedField = true
            }
        } header: {
            Text("Intensity Units")
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
