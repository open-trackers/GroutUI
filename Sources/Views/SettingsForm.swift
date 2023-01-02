//
//  SettingsForm.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct SettingsForm: View {
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    public init() {}

    // MARK: - Locals

    @AppStorage(alwaysAdvanceOnLongPressKey) var alwaysAdvanceOnLongPress: Bool = false

    #if os(iOS)
        @AppStorage(colorSchemeModeKey) var colorSchemeMode: ColorSchemeMode = .automatic
    #endif

    // MARK: - Views

    public var body: some View {
        Form {
            Section("\(Image(systemName: "checkmark")) Done Button") {
                Toggle("Always advance intensity on long press", isOn: $alwaysAdvanceOnLongPress)
            }

            #if os(iOS)
                Section("Color Scheme") {
                    Picker("Color", selection: $colorSchemeMode) {
                        ForEach(ColorSchemeMode.allCases, id: \.self) { mode in
                            Text(mode.description).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Button(action: {
                    router.path.append(MyRoutes.about)
                }) {
                    Text("About \(displayName)")
                }
            #endif
        }
        .navigationTitle("Settings")
    }
    
    private var displayName: String {
        Bundle.main.displayName ?? "unknown"
    }
}

struct SettingsForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsForm()
        }
    }
}
