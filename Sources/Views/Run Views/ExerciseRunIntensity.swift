//
//  ExerciseRunIntensity.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExerciseRunIntensity: View {
    @ObservedObject var exercise: Exercise
    #if os(watchOS)
        @Binding var middleMode: ExerciseMiddleRowMode
    #endif

    var body: some View {
        #if os(watchOS)
            Stepper(value: $exercise.lastIntensity,
                    in: 0.0 ... Exercise.intensityMaxValue,
                    step: exercise.intensityStep) {
                intensityText
                    .modify {
                        if #available(iOS 16.1, watchOS 9.1, *) {
                            $0.fontDesign(.rounded)
                        } else {
                            $0
                        }
                    }
            } onEditingChanged: { _ in
                Haptics.play()
            }
            .symbolRenderingMode(.hierarchical)
            .disabled(exercise.isDone)
            .foregroundColor(textTintColor)
            .contentShape(Rectangle())
            .onTapGesture(perform: tapAction)
        #elseif os(iOS)
            GroupBox {
                GroutStepper(value: $exercise.lastIntensity,
                             in: 0.0 ... Exercise.intensityMaxValue,
                             step: exercise.intensityStep) {
                    intensityText
                }
                .disabled(exercise.isDone)
                .foregroundColor(textTintColor)
            } label: {
                Text("Intensity")
                    .foregroundStyle(.tint)
            }
        #endif
    }

    private var intensityText: some View {
        TitleText(
            exercise.formatIntensity(exercise.lastIntensity, withUnits: true)
        )
    }

    private var textTintColor: Color {
        exercise.isDone ? completedColor : .primary
    }

    // MARK: - Actions

    #if os(watchOS)
        private func tapAction() {
            Haptics.play()

            middleMode = .settings
        }
    #endif
}

struct ExerciseRunIntensity_Previews: PreviewProvider {
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
        let ctx = PersistenceManager.getPreviewContainer().viewContext
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
