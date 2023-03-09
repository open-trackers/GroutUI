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

    // MARK: - Parameters

    @ObservedObject private var appSetting: AppSetting

    public init(appSetting: AppSetting) {
        self.appSetting = appSetting
    }

    // MARK: - Locals

    #if os(watchOS)
        // NOTE no longer saving the tab in scene storage, because it has been
        // annoying to not start out at the first tab when navigating to detail.
        // @SceneStorage("exercise-defaults-tab") private var selectedTab =
        @State private var selectedTab: Int = 0
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
    }

    #if os(watchOS)
        private var platformView: some View {
            TabView(selection: $selectedTab) {
                Form {
                    ExerciseVolume(sets: $appSetting.defExSets,
                                   repetitions: $appSetting.defExReps,
                                   tint: exerciseColor)
                }
                .tag(0)

                Form {
                    ExerciseIntensity(intensity: $appSetting.defExIntensity,
                                      intensityStep: $appSetting.defExIntensityStep,
                                      units: $appSetting.defExUnits,
                                      tint: exerciseColor)
                }
                .tag(1)
            }
            .tabViewStyle(.page)
            .navigationTitle {
                Text(title)
                    .foregroundColor(exerciseColorDarkBg)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
                        }
                    }
            }
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            Form {
                ExerciseVolume(sets: $appSetting.defExSets,
                               repetitions: $appSetting.defExReps,
                               tint: exerciseColor)

                ExerciseIntensity(intensity: $appSetting.defExIntensity,
                                  intensityStep: $appSetting.defExIntensityStep,
                                  units: $appSetting.defExUnits,
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
}

// struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
// }
