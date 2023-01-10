//
//  AddExerciseButton.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import GroutLib

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "AddExerciseButton")

public struct AddExerciseButton<Label>: View
    where Label: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    private var routine: Routine
    private var label: () -> Label

    public init(routine: Routine,
                label: @escaping () -> Label)
    {
        self.routine = routine
        self.label = label

        let sort = [NSSortDescriptor(keyPath: \Exercise.userOrder, ascending: true)]
        let pred = NSPredicate(format: "routine = %@", routine)
        _exercises = FetchRequest<Exercise>(entity: Exercise.entity(),
                                            sortDescriptors: sort,
                                            predicate: pred)
    }

    // MARK: - Locals

    @FetchRequest private var exercises: FetchedResults<Exercise>

    // MARK: - Views

    public var body: some View {
        Button(action: addAction, label: label)
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        exercises.last?.userOrder ?? 0
    }

    // MARK: - Actions

    private func addAction() {
        withAnimation {
            let nu = Exercise.create(viewContext, userOrder: maxOrder + 1)
            nu.name = "New Exercise"
            nu.routine = routine
            do {
                try PersistenceManager.shared.save(forced: true)
                router.path.append(MyRoutes.exerciseDetail(nu.uriRepresentation))
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
        }
    }
}

struct AddExerciseButton_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        return AddExerciseButton(routine: routine) {
            Text("Add Exercise")
        }
    }
}
