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
import TrackerUI

struct ExerciseRunIntensity: View {
    @ObservedObject var exercise: Exercise
    let labelFont: Font
    let onTap: () -> Void

    init(exercise: Exercise,
         labelFont: Font = .headline,
         onTap: @escaping () -> Void)
    {
        self.exercise = exercise
        self.labelFont = labelFont
        self.onTap = onTap
    }

    #if os(watchOS)
        private let maxFontSize: CGFloat = 60
    #elseif os(iOS)
        private let maxFontSize: CGFloat = 100
    #endif

    var body: some View {
        #if os(watchOS)
            Stepper(value: $exercise.lastIntensity,
                    in: Exercise.intensityRange,
                    step: exercise.intensityStep)
            {
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
            .onTapGesture(perform: onTap)
        #elseif os(iOS)
            GroupBox {
                GroutStepper(value: $exercise.lastIntensity,
                             in: Exercise.intensityRange,
                             step: exercise.intensityStep)
                {
                    intensityText
                }

                .disabled(exercise.isDone)
                .foregroundColor(textTintColor)
            } label: {
                Text("Intensity")
                    .font(labelFont)
                    .foregroundStyle(.tint)
            }
        #endif
    }

    private var intensityText: some View {
        TitleText(exercise.formattedIntensity(exercise.lastIntensity, withUnits: true),
                  maxFontSize: maxFontSize)
    }

    private var textTintColor: Color {
        exercise.isDone ? completedColor : .primary
    }
}

struct ExerciseRunIntensity_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        #if os(watchOS)
            @State var middleMode: ExerciseMiddleRowMode = .intensity
        #endif
        var body: some View {
            ExerciseRunIntensity(exercise: exercise) {}
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = Exercise.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.lastIntensity = 10.0
        e1.intensityStep = 7.0
        // e1.units = Units.kilograms.rawValue
        return NavigationStack {
            TestHolder(exercise: e1)
        }
    }
}
