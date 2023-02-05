//
//  File.swift
//
//
//  Created by Ahmed Shaban on 18/01/2023.
//

import GroutLib
import SwiftUI

struct DefaultUnitStored {
    static let DefaultUnit = DefaultUnitStored()
    @AppStorage("defaultUnitStored") public var defaultUnitStored = 2
    private init() {}
}

struct DefaultExercise: View {
    static let defaultExercise = DefaultExercise()
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("defaultSet") public var defaultSet = 3
    @AppStorage("defaultRep") public var defaultRep = 12
    @AppStorage("defaultIntensity") public var defaultIntensity = 10.0

    @State var defaultUnit: Units = (Units(rawValue: Int16(DefaultUnitStored.DefaultUnit.defaultUnitStored)) ?? .kilograms)

    private var tint: Color {
        colorScheme == .light ? exerciseColorLiteBg : exerciseColorDarkBg
    }

    private init() {}

    var body: some View {
        // MARK: Sets

        Section {
            Stepper(value: $defaultSet, in: 0 ... 10, step: 1) {
                Text("\(defaultSet)")
                    .font(.title) // for consistency (use same intensity step font)
            } onEditingChanged: { _ in
                Haptics.play()
            }
        } header: {
            Text("Set Count")
                .foregroundStyle(.tint)
        }

        // MARK: Repetitions

        Section {
            Stepper(value: $defaultRep, in: 0 ... 100, step: 1) {
                Text("\(defaultRep)")
                    .font(.title) // for consistency (use same intensity step font)
            } onEditingChanged: { _ in
                Haptics.play()
            }
        } header: {
            Text("Repetition Count")
                .foregroundStyle(.tint)
        }

        // MARK: Intensity Step

        Section {
            Stepper(value: $defaultIntensity, in: 0.1 ... 25.0, step: 0.1) {
                Text(String(format: "%.1f", defaultIntensity))
                    .font(.title) // to avoid decimal viewed on two lines
            } onEditingChanged: { _ in
                Haptics.play()
            }
        } header: {
            Text("Intensity Step")
                .foregroundStyle(.tint)
        }

        // MARK: Units

        Section {
            Picker(selection: $defaultUnit,
                   label: Text("Choose Unit")) {
                ForEach(Units.allCases, id: \.self) { unit in
                    Text(unit.formattedDescription)
                }
            }
            .onChange(of: defaultUnit) { _ in
                Haptics.play()
                storeUnit()
            }
            .pickerStyle(.wheel)
            .frame(height: 50) // the default height is too small
            .foregroundStyle(.tint)
        }

        // MARK: Reset

        Button(action: {
            Haptics.play()
            resetSettings()
        }) {
            HStack {
                Spacer()
                Text("Reset")
                    .foregroundStyle(.tint)
                Spacer()
            } // spacers to center button title
        }
        .font(.title2) // Make the button bigger
        .buttonStyle(PlainButtonStyle()) // prevent UI from triggering the button
    }

    // MARK: Actions

    private func resetSettings() {
        defaultSet = 3
        defaultRep = 12
        defaultIntensity = 10.0
        DefaultUnitStored.DefaultUnit.defaultUnitStored = 2
        defaultUnit = .kilograms
    }

    private func storeUnit() {
        DefaultUnitStored.DefaultUnit.defaultUnitStored = Int(defaultUnit.rawValue)
        print("Current Unit Stored is: \(Units(rawValue: Int16(DefaultUnitStored.DefaultUnit.defaultUnitStored))?.formattedDescription ?? "No Unit Selected")")
    }
}
