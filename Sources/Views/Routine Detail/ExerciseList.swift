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
import TrackerUI

public struct ExerciseList: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine

        let sort = [NSSortDescriptor(keyPath: \Exercise.userOrder, ascending: true)]
        let pred = NSPredicate(format: "routine == %@", routine)
        _exercises = FetchRequest<Exercise>(entity: Exercise.entity(),
                                            sortDescriptors: sort,
                                            predicate: pred)
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: ExerciseList.self))

    @FetchRequest private var exercises: FetchedResults<Exercise>

    // MARK: - Views

    public var body: some View {
        List {
            ForEach(exercises, id: \.self) { exercise in
                Button(action: { detailAction(exercise: exercise) }) {
                    Text("\(exercise.name ?? "unknown")")
                        .foregroundColor(exerciseColor)
                }
                #if os(watchOS)
                .listItemTint(exerciseListItemTint)
                #elseif os(iOS)
                .listRowBackground(exerciseListItemTint)
                #endif
            }
            .onMove(perform: moveAction)
            .onDelete(perform: deleteAction)

            #if os(watchOS)
                AddExerciseButton(routine: routine)
                    .font(.title3)
                    .tint(exerciseColorDarkBg)
                    .foregroundStyle(.tint)
            #endif
        }
        #if os(iOS)
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem {
                AddExerciseButton(routine: routine)
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
        logger.notice("\(#function)")
        Haptics.play()

        router.path.append(GroutRoute.exerciseDetail(exercise.uriRepresentation))
    }

    private func deleteAction(offsets: IndexSet) {
        logger.notice("\(#function)")
        offsets.map { exercises[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        logger.notice("\(#function)")
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
        @State var navData: Data?
        var body: some View {
            GroutNavStack(navData: $navData) {
                ExerciseList(routine: routine)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
    }
}
