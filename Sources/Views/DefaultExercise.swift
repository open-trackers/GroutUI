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
        VStack {
            //MARK: Sets
            Section {
                Stepper(value: $defaultSet, in: 0 ... 10, step: 1) {
                    Text("\(defaultSet)")
                        .font(.custom("Arial", size: 27))
                } onEditingChanged: { _ in
                    Haptics.play()
                }
                //            .tint(tint)
            } header: {
                Text("Set Count")
                //                .foregroundStyle(tint)
            }
            
            //MARK: Repetitions
            Section {
                Stepper(value: $defaultRep, in: 0 ... 100, step: 1) {
                    Text("\(defaultRep)")
                        .font(.custom("Arial", size: 27))
                } onEditingChanged: { _ in
                    Haptics.play()
                }
                //            .tint(tint)
            } header: {
                Text("Repetition Count")
                //                .foregroundStyle(tint)
            }
            
            //MARK: Intensity Step
            Section {
                Stepper(value: $defaultIntensity, in: 0.1 ... 25.0, step: 0.1) {
                    Text(String(format: "%.1f", defaultIntensity))
                        .font(.custom("Arial", size: 27))
                } onEditingChanged: { _ in
                    Haptics.play()
                }
                //                    .tint(tint)
            } header: {
                Text("Intensity Step")
                //                 .foregroundStyle(tint)
            }
            Spacer()
            //MARK: Units
            Section {
                Picker("Choose Unit", selection: $defaultUnit) {
                    ForEach(Units.allCases, id: \.self) { unit in
                        Text(unit.formattedDescription)
                    }
                }
                .onChange(of: defaultUnit) { _ in
                    Haptics.play()
                    DefaultUnitStored.DefaultUnit.defaultUnitStored = Int(defaultUnit.rawValue)
                    print("Current Unit Stored is: \(Units(rawValue: Int16(DefaultUnitStored.DefaultUnit.defaultUnitStored))?.formattedDescription ?? "No Unit Selected")")
                }
                .pickerStyle(.wheel)
                .frame(height: 50)
            }
//
            
            //MARK: Reset
                Button(action: {
                    Haptics.play()
                    defaultSet = 3
                    defaultRep = 12
                    defaultIntensity = 10.0
                    DefaultUnitStored.DefaultUnit.defaultUnitStored = 2
                    defaultUnit = .kilograms
                }) {
                    Text("Reset")
//                        .foregroundStyle(tint)
                }
                .frame(width: 50)
                .frame(height: 30)
                .padding()
                .foregroundColor(.orange)
                .buttonStyle(PlainButtonStyle()) //Button triggered by UI seems to be an issue with SwiftUI generally. using .buttonStyle(PlainButtonStyle()) will fix the problem. https://stackoverflow.com/questions/68541909/two-buttons-in-swift-ui-on-watchos
        }
    }
}

/*I have the same issue, didn't matter how I modified the Picker, put it inside List, ScrollView, Form, etc. Same warning. Seems to me as you mention it is a bug on SwiftUI for watchOS, but I would think is harmless to ignore the warning (I hope...) –
 vicegax
 Oct 12, 2022 at 17:16 - StackoverFlow
 */
