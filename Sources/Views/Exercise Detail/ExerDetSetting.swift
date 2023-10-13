//
//  ExerDetSetting.swift
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

struct ExDetSetting: View {
    // MARK: - Parameters

    @Binding var value: Int16
    let tint: Color
    let title: String
    var forceFocus: Bool = false

    // MARK: - Views

    var body: some View {
        Section {
            ValueStepper(value: $value,
                         in: Exercise.settingRange,
                         step: 1,
                         specifier: "%d",
                         forceFocus: forceFocus)
                .tint(tint)
        } header: {
            Text(title)
        }
    }
}

struct ExDetSetting_Previews: PreviewProvider {
    static var previews: some View {
        Form { ExDetSetting(value: .constant(100), tint: .blue, title: "Hello") }
    }
}
