//
//  File.swift
//  
//
//  Created by Ahmed Shaban on 18/01/2023.
//

import SwiftUI
import GroutLib



struct DefaultExercise: View {
    @AppStorage("defaultSet")  public  var defaultSet = 0
    @AppStorage("defaultRep") public var defaultRep = 0
    @AppStorage("defaultIntensity") public var defaultIntensity = 0.1
    @AppStorage("defaultUnitStored") public var defaultUnitStored = "Kg"
    @State var defaultUnit = Units.kilograms
    
    var body: some View {
        VStack {
                //MARK: Sets
                Section {
                    Stepper(value: $defaultSet, in: 0 ... 10, step: 1) {
                        Text("\(defaultSet)")
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
                    } onEditingChanged: { _ in
                        Haptics.play()
                    }
                    //            .tint(tint)
                } header: {
                    Text("Repetition Count")
                    //                .foregroundStyle(tint)
                }
                
                
                //MARK: Intensity
                Section {
                    Stepper(value: $defaultIntensity, in: 0.1 ... 25.0, step: 0.1) {
                        Text(String(format: "%.1f", defaultIntensity))
                        
                    } onEditingChanged: { _ in
                        Haptics.play()
                    }
                    //                    .tint(tint)
                } header: {
                    Text("Intensity")
                    //                 .foregroundStyle(tint)
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
                        defaultUnitStored = defaultUnit.description
                        print(defaultUnitStored)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }
            }
    }
}

/* I have the same issue, didn't matter how I modified the Picker, put it inside List, ScrollView, Form, etc. Same warning. Seems to me as you mention it is a bug on SwiftUI for watchOS, but I would think is harmless to ignore the warning (I hope...) –
 vicegax
  Oct 12, 2022 at 17:16 - StackoverFlow*/
