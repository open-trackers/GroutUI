//
//  AddExerciseButton.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import TextFieldPreset

import GroutLib
import TrackerUI

public struct AddExerciseButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: AddExerciseButton.self))

    #if os(iOS)
        @State private var showBulkAdd = false
        @State private var selected = Set<ExercisePreset>()
    #endif

    // MARK: - Views

    public var body: some View {
        AddElementButton(elementName: "Exercise",
                         onLongPress: longPressAction,
                         onCreate: createAction,
                         onAfterSave: afterSaveAction)
        #if os(iOS)
            .sheet(isPresented: $showBulkAdd) {
                NavigationStack {
                    BulkPresetsPicker(selected: $selected,
                                      presets: exercisePresets,
                                      label: { Text($0.description) })
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", action: cancelBulkAddAction)
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add Exercises", action: bulkAddAction)
                                    .disabled(selected.count == 0)
                            }
                        }
                }
            }
        #endif
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        do {
            return try Exercise.maxUserOrder(viewContext, routine: routine) ?? 0
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
        return 0
    }

    // MARK: - Actions

    #if os(iOS)
        private func cancelBulkAddAction() {
            showBulkAdd = false
        }
    #endif

    #if os(iOS)
        private func bulkAddAction() {
            do {
                // produce an ordered array of presets from the unordered set
                let presets = exercisePresets.flatMap(\.value).filter { selected.contains($0) }

                try Exercise.bulkCreate(viewContext, routine: routine, presets: presets)
                try viewContext.save()
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
            showBulkAdd = false
        }
    #endif

    private func longPressAction() {
        #if os(watchOS)
            Haptics.play(.warning)
        #elseif os(iOS)
            showBulkAdd = true
        #endif
    }

    private func createAction() -> Exercise {
        let nu = Exercise.create(viewContext,
                                 routine: routine,
                                 userOrder: maxOrder + 1)
        do {
            try nu.populate(viewContext)
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
        return nu
    }

    private func afterSaveAction(_ nu: Exercise) {
        router.path.append(GroutRoute.exerciseDetail(nu.uriRepresentation))
    }
}

struct AddExerciseButton_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        return AddExerciseButton(routine: routine)
    }
}
