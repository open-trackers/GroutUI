//
//  ExDetRoutine.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import TextFieldPreset

import GroutLib
import TrackerUI

struct ExDetRoutine: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Parameters

    @ObservedObject private var routine: Routine
    private var onSelect: (UUID?) -> Void

    init(routine: Routine,
         onSelect: @escaping (UUID?) -> Void)
    {
        self.routine = routine
        self.onSelect = onSelect
        let sort = Routine.byName()
        _routines = FetchRequest<Routine>(entity: Routine.entity(),
                                          sortDescriptors: sort)
        _selected = State(initialValue: routine.archiveID)
    }

    // MARK: - Locals

    @FetchRequest private var routines: FetchedResults<Routine>

    @State private var selected: UUID?

//    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
//                                category: String(describing: ExDetRoutine.self))

    // MARK: - Views

    var body: some View {
        platformView
            .onChange(of: selected) { nuArchiveID in
                onSelect(nuArchiveID)
            }
    }

    #if os(watchOS)
        private var platformView: some View {
            Picker("Routine", selection: $selected) {
                ForEach(routines) { element in
                    Text(element.wrappedName)
                        .tag(element.archiveID)
                }
            }
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            Section("Routine") {
                Picker("", selection: $selected) {
                    ForEach(routines) { element in
                        HStack {
                            Text(element.wrappedName)
                            Spacer()
                        }
                        .tag(element.archiveID)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
    #endif
}

struct ExDetRoutine_Previews: PreviewProvider {
    struct TestHolder: View {
        @ObservedObject var routine: Routine
        var body: some View {
            ExDetRoutine(routine: routine, onSelect: { _ in })
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine1 = Routine.create(ctx, userOrder: 0)
        routine1.name = "Beverage"
        let routine2 = Routine.create(ctx, userOrder: 1)
        routine2.name = "Meat"
        try? ctx.save()
        return Form { TestHolder(routine: routine2) }
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
