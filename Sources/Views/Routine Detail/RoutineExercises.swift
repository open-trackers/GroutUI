//
//  RoutineExercises.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib
import TrackerUI

public struct RoutineExercises: View {
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    @ObservedObject private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine
    }

    // MARK: - Locals

    // MARK: - Views

    public var body: some View {
        Section {
            Button(action: exerciseListAction) {
                HStack {
                    Text("Exercises")
                    Spacer()
                    Text(exerciseCount > 0 ? String(format: "%d", exerciseCount) : "none")
                    #if os(watchOS)
                        .foregroundStyle(exerciseColorDarkBg)
                    #endif
                }
            }
        } footer: {
            Text("The exercises available for this routine.")
        }
    }

    // MARK: - Properties

    private var exerciseCount: Int {
        routine.exercises?.count ?? 0
    }

    // MARK: - Actions

    private func exerciseListAction() {
        router.path.append(GroutRoute.exerciseList(routine.uriRepresentation))
    }
}

struct RoutineExercises_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            Form {
                RoutineExercises(routine: routine)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Beverage"
        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.routine = routine
        exercise.name = "Stout"
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
