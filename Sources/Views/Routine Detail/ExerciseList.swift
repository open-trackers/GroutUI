//
//  ExerciseList.swift
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
                            category: "ExerciseList")

public struct ExerciseList: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine

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
        List {
            ForEach(exercises, id: \.self) { exercise in
                Button(action: { detailAction(exercise: exercise) }) {
                    Text("\(exercise.name ?? "unknown")")
                }
                .buttonStyle(.borderless)
            }
            .onMove(perform: moveAction)
            .onDelete(perform: deleteAction)
            .listItemTint(exerciseListItemTint)
            .tint(exerciseColor)

            #if os(watchOS)
                AddExerciseButton(routine: routine) {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .font(.title3)
                .tint(exerciseColorDarkBg)
                .foregroundStyle(.tint)
            #endif
        }
        #if os(iOS)
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem {
                AddExerciseButton(routine: routine) {
                    Text("Add")
                        .tint(exerciseColor)
                }
            }
        }
        #endif
    }

    // MARK: - Properties

    private var exerciseColor: Color {
        colorScheme == .light ? exerciseColorLiteBg : exerciseColorDarkBg
    }

    // MARK: - Actions

    private func detailAction(exercise: Exercise) {
        router.path.append(MyRoutes.exerciseDetail(exercise.uriRepresentation))
    }

    private func deleteAction(offsets: IndexSet) {
        offsets.map { exercises[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        Exercise.move(exercises, from: source, to: destination)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

struct ExerciseList_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            NavigationStack {
                ExerciseList(routine: routine)
            }
        }
    }

    static var previews: some View {
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
    }
}
