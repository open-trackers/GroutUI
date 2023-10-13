//
//  RoutDetName.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import TextFieldPreset

import GroutLib
import TrackerUI

public struct RoutDetName: View {
    // MARK: - Parameters

    @ObservedObject private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine
    }

    // MARK: - Locals

    // MARK: - Views

    public var body: some View {
        Section {
            TextFieldPreset($routine.wrappedName,
                            prompt: "Enter routine name",
                            axis: .vertical,
                            presets: routinePresets)
            {
                Text($0.description)
                    .foregroundStyle(.tint)
            }
            #if os(watchOS)
            .padding(.bottom)
            #endif
            #if os(iOS)
            .font(.title3)
            #endif
            .textInputAutocapitalization(.words)
        } header: {
            Text("Name")
        }
    }

    // MARK: - Properties
}

struct RoutDetName_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            Form {
                RoutDetName(routine: routine)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Beverage"
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
