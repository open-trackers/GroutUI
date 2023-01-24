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
import GroutLib

public struct SettingsForm<Content>: View
where Content: View
{
    @EnvironmentObject private var router: MyRouter
    
    // MARK: - Parameters
    
    private var defaultSettings: () -> Content
    public init(@ViewBuilder content: @escaping () -> Content = { DefaultExercise.defaultExercise }) {
        self.defaultSettings = content
    }
    
    // MARK: - Locals
    @AppStorage(alwaysAdvanceOnLongPressKey) var alwaysAdvanceOnLongPress: Bool = false
    @AppStorage(logToHistoryKey) var logToHistory: Bool = true
    
    // MARK: - Views
    public var body: some View {
        Form {
            Section {
                Toggle("Always advance intensity on long press", isOn: $alwaysAdvanceOnLongPress)
                    .tint(.accentColor)
                
            } header: {
                Text("\(Image(systemName: "checkmark")) Done Button")
                    .foregroundStyle(.tint)
            }
            
            Section {
                Toggle("Log activity", isOn: $logToHistory)
                    .tint(.accentColor)
            } header: {
                Text("\(Image(systemName: "fossil.shell.fill")) History")
                    .foregroundStyle(.tint)
            } footer: {
#if os(watchOS)
                Text("Recent history will be stored locally for up to 1 year. Periodically run iPhone/iPad app for long-term storage and review.")
#elseif os(iOS)
                Text("History can be reviewed from the home screen.")
#endif
            }
            defaultSettings()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsForm()
        }
    }
}
