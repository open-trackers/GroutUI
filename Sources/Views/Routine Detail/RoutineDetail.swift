//
//  RoutineDetail.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

public struct RoutineDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    @ObservedObject private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine

        _color = State(initialValue: routine.getColor() ?? .clear)
    }

    // MARK: - Locals

    // Using .clear as a local non-optional proxy for nil, because picker won't
    // work with optional.
    // When saved, the color .clear assigned is nil.
    @State private var color: Color

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: RoutineDetail.self))

    #if os(watchOS)
        // NOTE no longer saving the tab in scene storage, because it has been
        // annoying to not start out at the first tab when navigating to detail.
        // @SceneStorage("routine-detail-tab") private var selectedTab: Int = 0
        @State private var selectedTab: Tab = .first

        enum Tab: Int, ControlBarProtocol {
            case name = 1
            case colorImage = 2
            case exercises = 3

            static var first: Tab = .name
            static var last: Tab = .exercises

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
            .onDisappear(perform: onDisappearAction)
    }

    #if os(watchOS)
        private var platformView: some View {
            VStack {
                TabView(selection: $selectedTab) {
                    Form {
                        RoutDetName(routine: routine)
                    }
                    .tag(Tab.name)
                    Form {
                        FormColorPicker(color: $color)
                        RoutDetImage(routine: routine)
                    }
                    .tag(Tab.colorImage)
                    FakeSection(title: "Exercises") {
                        ExerciseList(routine: routine)
                    }
                    .tag(Tab.exercises)
                }
                .animation(.easeInOut(duration: 0.25), value: selectedTab)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                ControlBar(selection: $selectedTab, tint: routineColor)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
            }
            .ignoresSafeArea(.all, edges: [.bottom]) // NOTE allows control bar to be at bottom
            .navigationTitle {
                NavTitle(title, color: routineColor)
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
                RoutDetName(routine: routine)
                FormColorPicker(color: $color)
                RoutDetImage(routine: routine)
                RoutDetExercises(routine: routine)
            }
            .navigationTitle(title)
        }
    #endif

    // MARK: - Properties

    private var title: String {
        "Routine"
    }

    #if os(iOS)
        private var exerciseCount: Int {
            routine.exercises?.count ?? 0
        }
    #endif

    // MARK: - Actions

    private func onDisappearAction() {
        do {
            routine.setColor(color != .clear ? color : nil)
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

struct RoutineDetail_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            NavigationStack {
                RoutineDetail(routine: routine)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, routine: routine, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
            .accentColor(.orange)
    }
}
