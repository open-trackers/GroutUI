//
//  ExerciseIntensity.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

public struct ExerciseIntensity: View {
    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise
    private let tint: Color

    public init(exercise: Exercise, tint: Color) {
        self.exercise = exercise
        self.tint = tint
        _units = State(initialValue: exercise.units)
    }

    // MARK: - Locals

    @State private var units: Int16

    private let intensityRange: ClosedRange<Float> = 0 ... Exercise.intensityMaxValue
    private let intensityStepRange: ClosedRange<Float> = 0.1 ... 25
    private let intensityStep: Float = 0.1

    // MARK: - Views

    public var body: some View {
        Section {
            Stepper(value: $exercise.lastIntensity, in: intensityRange, step: exercise.intensityStep) {
                intensityText(exercise.lastIntensity)
            } onEditingChanged: { _ in
                Haptics.play()
            }
            .tint(tint)
//            Button(action: { Haptics.play(); exercise.lastIntensity = 0 }) {
//                Text("Set to zero (0)")
//                    .foregroundStyle(tint)
//            }
        } header: {
            Text("Intensity")
                .foregroundStyle(tint)
        }

        Section {
            Stepper(value: $exercise.intensityStep, in: intensityStepRange, step: intensityStep) {
                intensityText(exercise.intensityStep)
            } onEditingChanged: { _ in
                Haptics.play()
            }
            .tint(tint)
//            Button(action: { Haptics.play(); exercise.intensityStep = 1 }) {
//                Text("Set to one (1)")
//                    .foregroundStyle(tint)
//            }
        } header: {
            Text("Intensity Step")
                .foregroundStyle(tint)
        }

        Section {
            Picker(selection: $units) {
                ForEach(Units.allCases, id: \.self) { unit in
                    Text(unit.formattedDescription)
                        .font(.title3)
                        .tag(unit.rawValue)
                }
            } label: {
                EmptyView()
            }
            .onChange(of: units) { _ in
                Haptics.play()
            }
            #if os(watchOS)
            .pickerStyle(.wheel)
            #endif
            .onChange(of: units) {
                exercise.units = $0
            }
        } header: {
            Text("Intensity Units")
                .foregroundStyle(tint)
        }

        Section {
            Toggle(isOn: $exercise.invertedIntensity) {
                Text("Inverted")
            }
            .tint(tint)
        } header: {
            Text("Advance Direction")
                .foregroundStyle(tint)
        } footer: {
            Text("Example: if inverted with step of 5, advance from 25 to 20")
        }
    }

    private func intensityText(_ intensityValue: Float) -> some View {
        Text(exercise.formatIntensity(intensityValue, withUnits: true))
            // NOTE needed on watchOS to reduce text size
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        #if os(watchOS)
            .modify {
                if #available(iOS 16.1, watchOS 9.1, *) {
                    $0.fontDesign(.rounded)
                }
            }
        #endif
    }
}

struct ExerciseIntensity_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.units = Units.kilograms.rawValue
        return Form { ExerciseIntensity(exercise: exercise, tint: .green) }
    }
}
