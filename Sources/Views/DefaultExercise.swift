//
//  File.swift
//  
//
//  Created by Ahmed Shaban on 18/01/2023.
//

import SwiftUI
import GroutLib

struct DefaultUnitStored {
    static let DefaultUnit = DefaultUnitStored()
    @AppStorage("defaultUnitStored") public var defaultUnitStored = 2
    private init() {}
}

struct DefaultExercise: View {
    
    static let defaultExercise = DefaultExercise()
    
    @AppStorage("defaultSet")  public  var defaultSet = 3
    @AppStorage("defaultRep") public var defaultRep = 12
    @AppStorage("defaultIntensity") public var defaultIntensity = 10.0
    
    @State var defaultUnit: Units = (Units(rawValue: Int16(DefaultUnitStored.DefaultUnit.defaultUnitStored)) ?? .kilograms)
    
    private init() {}

    var body: some View {

            //MARK: Sets
            Section {
                Stepper(value: $defaultSet, in: 0 ... 10, step: 1) {
                    Text("\(defaultSet)")
                        .font(.title) // for consistency (use same intensity step font)
                } onEditingChanged: { _ in
                    Haptics.play()
                }
            } header: {
                Text("Set Count")
            }
            
            //MARK: Repetitions
            Section {
                Stepper(value: $defaultRep, in: 0 ... 100, step: 1) {
                    Text("\(defaultRep)")
                        .font(.title) // for consistency (use same intensity step font)
                } onEditingChanged: { _ in
                    Haptics.play()
                }
            } header: {
                Text("Repetition Count")
            }
            
            //MARK: Intensity Step
            Section {
                Stepper(value: $defaultIntensity, in: 0.1 ... 25.0, step: 0.1) {
                    Text(String(format: "%.1f", defaultIntensity))
                        .font(.title) // to avoid decimal viewed on two lines
                } onEditingChanged: { _ in
                    Haptics.play()
                }
            } header: {
                Text("Intensity Step")
            }
            //MARK: Units
            Section {
                Picker("Choose Unit", selection: $defaultUnit) {
                    ForEach(Units.allCases, id: \.self) { unit in
                        Text(unit.formattedDescription)
                    }
                }
                .onChange(of: defaultUnit) { _ in
                    Haptics.play()
                    storeUnit()
                }
                .pickerStyle(.wheel)
                .frame(height: 50) //the default height is too small
            }
            //MARK: Reset
                Button(action: {
                    Haptics.play()
                    resetSettings()
                }) {
                    HStack { Spacer(); Text("Reset"); Spacer(); } // center button title
                }
                .foregroundColor(.orange)
                .font(.title2) // Highlight the button
                .buttonStyle(PlainButtonStyle()) // prevent UI from triggering the button
    }
    
    //MARK: Actions
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

