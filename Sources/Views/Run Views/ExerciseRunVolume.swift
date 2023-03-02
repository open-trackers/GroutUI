//
//  ExerciseRunVolume.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

import GroutLib
import TrackerUI

struct ExerciseRunVolume: View {
    @ObservedObject var exercise: Exercise
    var onEdit: (URL) -> Void
    #if os(watchOS)
        @Binding var middleMode: ExerciseMiddleRowMode
    #endif

    var body: some View {
        #if os(watchOS)
            ExerciseRunMiddleRow(imageName: "dumbbell.fill",
                                 imageColor: exerciseSetsColor,
                                 onDetail: { onEdit(exercise.uriRepresentation) },
                                 onTap: tapAction) {
                volumeText
            }
        #elseif os(iOS)
            GroupBox {
                volumeText
                    .padding()

                    // NOTE: needed to vertically expand GroupBox
                    .frame(maxHeight: .infinity)
            } label: {
                Label("Sets/Reps", systemImage: "dumbbell.fill")
                    .foregroundStyle(.tint)
            }
        #endif
    }

    private var volumeText: some View {
        TitleText("\(exercise.sets)/\(exercise.repetitions)")
            .foregroundStyle(textTintColor)
            .lineLimit(1)
            .modify {
                if #available(iOS 16.1, watchOS 9.1, *) {
                    $0.fontDesign(.monospaced)
                } else {
                    $0.monospaced()
                }
            }
    }

    private var textTintColor: Color {
        exercise.isDone ? completedColor : .primary
    }

    // MARK: - Actions

    #if os(watchOS)
        private func tapAction() {
            Haptics.play()

            middleMode = .intensity
        }
    #endif
}

struct ExerciseRunVolume_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        var body: some View {
            ExerciseRun(exercise: exercise,
                        routineStartedAt: Date.now,
                        onNextIncomplete: { _ in },
                        hasNextIncomplete: { true },
                        onEdit: { _ in })
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = Exercise.create(ctx, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.routine = routine
        e1.primarySetting = 4
        e1.intensityStep = 7.1
        return NavigationStack {
            TestHolder(exercise: e1)
        }
    }
}
