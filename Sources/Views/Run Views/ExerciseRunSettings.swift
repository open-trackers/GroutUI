//
//  ExerciseRunSettings.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

struct ExerciseRunSettings: View {
    @ObservedObject var exercise: Exercise
    var onEdit: (Exercise) -> Void
    #if os(watchOS)
        @Binding var middleMode: ExerciseMiddleRowMode
    #endif

    var body: some View {
        #if os(watchOS)
            ExerciseRunMiddleRow(imageName: "gearshape.fill",
                                 imageColor: exerciseGearColor,
                                 onDetail: { onEdit(exercise) },
                                 onTap: { middleMode = .volume }) {
                settingsText
            }
        #elseif os(iOS)
            GroupBox {
                settingsText

                    // NOTE: needed to vertically expand GroupBox
                    .frame(maxHeight: .infinity)
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
                    .foregroundStyle(.tint)
            }
        #endif
    }

    private var settingsText: some View {
        HStack {
            if exercise.primarySetting == 0, exercise.secondarySetting == 0 {
                TitleText("None")
                    .foregroundStyle(exerciseGearColor)
                    .padding()
            }

            Group {
                if exercise.primarySetting > 0 {
                    NumberImage(exercise.primarySetting, isCircle: true, disabled: exercise.isDone)
                }
                if exercise.secondarySetting > 0 {
                    NumberImage(exercise.secondarySetting, isCircle: false, disabled: exercise.isDone)
                }
            }
            #if os(watchOS)
            .padding(.vertical)
            #endif
        }
    }
}

struct ExerciseRunSettings_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        var body: some View {
            ExerciseRun(exercise: exercise,
                        onNextIncomplete: { _ in },
                        hasNextIncomplete: { true },
                        onEdit: { _ in })
        }
    }

    static var previews: some View {
        let ctx = PersistenceManager.preview.container.viewContext
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
