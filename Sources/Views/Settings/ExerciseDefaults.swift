//
//  ExerciseDefaults.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import TrackerLib
import TrackerUI

import GroutLib

import SwiftUI

struct ExerciseDefaults: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Parameters

    @ObservedObject private var appSetting: AppSetting

    public init(appSetting: AppSetting) {
        self.appSetting = appSetting
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: ExerciseDefaults.self))

    #if os(watchOS)
        // NOTE no longer saving the tab in scene storage, because it has been
        // annoying to not start out at the first tab when navigating to detail.
        // @SceneStorage("exercise-defaults-tab") private var selectedTab =
        @State private var selectedTab: Tab = .first

        enum Tab: Int, ControlBarProtocol {
            case sets = 1
            case reps = 2
            case intensity = 3
            case intensityStep = 4
            case intensityUnit = 5

            static var first: Tab = .sets
            static var last: Tab = .intensityUnit

            var previous: Tab? {
                Tab(rawValue: rawValue - 1)
            }

            var next: Tab? {
                Tab(rawValue: rawValue + 1)
            }
        }
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: disappearAction)
    }

    #if os(watchOS)
        private var platformView: some View {
            VStack {
                TabView(selection: $selectedTab) {
                    Form {
                        ExDetSets(sets: $appSetting.defExSets,
                                  tint: exerciseColor)
                    }
                    .tag(Tab.sets)

                    Form {
                        ExDetReps(repetitions: $appSetting.defExReps,
                                  tint: exerciseColor)
                    }
                    .tag(Tab.reps)

                    Form {
                        ExDetIntensity(intensity: $appSetting.defExIntensity,
                                       intensityStep: appSetting.defExIntensityStep,
                                       units: Units(rawValue: appSetting.defExUnits),
                                       tint: exerciseColor)
                    }
                    .tag(Tab.intensity)

                    Form {
                        ExDetIntensityStep(intensityStep: $appSetting.defExIntensityStep,
                                           units: Units(rawValue: appSetting.defExUnits),
                                           tint: exerciseColor)
                    }
                    .tag(Tab.intensityStep)

                    Form {
                        ExDetIntensityUnits(rawUnits: $appSetting.defExUnits,
                                            tint: exerciseColor)
                    }
                    .tag(Tab.intensityUnit)
                }
                .animation(.easeInOut(duration: 0.25), value: selectedTab)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                ControlBar(selection: $selectedTab, tint: exerciseColor)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
            }
            .ignoresSafeArea(.all, edges: [.bottom]) // NOTE allows control bar to be at bottom
            .navigationTitle {
                Text(title)
                    .foregroundColor(exerciseColorDarkBg)
//                    .onTapGesture {
//                        withAnimation {
//                            selectedTab = .first
//                        }
//                    }
            }
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            Form {
                ExDetSets(sets: $appSetting.defExSets,
                          tint: exerciseColor)
                ExDetReps(repetitions: $appSetting.defExReps,
                          tint: exerciseColor)
                ExDetIntensity(intensity: $appSetting.defExIntensity,
                               intensityStep: appSetting.defExIntensityStep,
                               units: Units(rawValue: appSetting.defExUnits),
                               tint: exerciseColor)
                ExDetIntensityStep(intensityStep: $appSetting.defExIntensityStep,
                                   units: Units(rawValue: appSetting.defExUnits),
                                   tint: exerciseColor)
                ExDetIntensityUnits(rawUnits: $appSetting.defExUnits,
                                    tint: exerciseColor)
            }
            .navigationTitle(title)
        }
    #endif

    private var title: String {
        "Exercise Defaults"
    }

    private var exerciseColor: Color {
        colorScheme == .light ? exerciseColorLiteBg : exerciseColorDarkBg
    }

    // MARK: - Actions

    private func disappearAction() {
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

// struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
// }
