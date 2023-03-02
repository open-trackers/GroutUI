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

    // MARK: - Views

    public var body: some View {
        AddElementButton(elementName: "Exercise",
                         onCreate: createAction,
                         onAfterSave: afterSaveAction)
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        do {
            return try Exercise.maxUserOrder(viewContext, routine: routine) ?? 0
        } catch {
            // logger.error("\(#function): \(error.localizedDescription)")
        }
        return 0
    }

    // MARK: - Actions

    private func createAction() -> Exercise {
        Exercise.create(viewContext,
                        routine: routine,
                        userOrder: maxOrder + 1,
                        name: "New Exercise")
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
