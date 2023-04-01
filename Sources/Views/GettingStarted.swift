//
//  GettingStarted.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib
import TrackerLib
import TrackerUI

struct GettingStarted: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Views

    var body: some View {
        Group {
            Text("Set up your first workout by:")

            Text("1. Adding a Routine")

            Text("2. Add one or more Exercises to that Routine")

            Text("3. Navigate back and tap Routine to start your workout!")
        }
        .font(.headline)
    }
}

struct GettingStarted_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GettingStarted()
                .accentColor(.blue)
        }
    }
}
