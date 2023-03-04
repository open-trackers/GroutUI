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

    // MARK: - Parameters

    @Binding var show: Bool

    // MARK: - Locals

    private let title = "Getting Started"

    // MARK: - Views

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    #if os(watchOS)
                        Text(title)
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    #endif
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            Text("Set up your first workout by:")

                            Text("1. Adding a Routine")

                            Text("2. Add one or more Exercises to that Routine")

                            Text("3. Navigate back and tap Routine to start your workout!")
                        }
                        .font(.headline)

                        Text("Look for the handy (\(Image(systemName: "line.3.horizontal.decrease"))) button to select a preset to reduce typing!")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()

                    AppIcon(name: "grt_icon")
                        .frame(width: geo.size.width / 4, height: geo.size.width / 4)
                }
                .onTapGesture {
                    show = false
                }
            }
        }
        #if os(iOS)
        .navigationTitle(title)
        #endif
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Close", action: { show = false })
//            }
//        }
    }
}

struct GettingStarted_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        return NavigationStack {
            GettingStarted(show: .constant(true))
                .accentColor(.blue)
        }
        .environment(\.managedObjectContext, manager.container.viewContext)
        .environmentObject(manager)
    }
}
