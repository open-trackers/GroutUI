//
//  RoutineDetail.swift
//
//
//  Created by Reed Esau on 12/25/22.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "RoutineDetail")

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
        @SceneStorage("routine-detail-tab") private var selectedTab: Int = 0
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: onDisappearAction)
    }

    #if os(watchOS)
        private var platformView: some View {
            TabView(selection: $selectedTab) {
                Form {
                    RoutineName(routine: routine)
                    RoutineImage(routine: routine)
                    FormColorPicker(color: $color)
                }
                .tabItem {
                    Text("Properties")
                }
                .tag(0)

                FakeSection(title: "Exercises") {
                    ExerciseList(routine: routine)
                }
                .tabItem {
                    Text("Exercises")
                }
                .tag(1)
            }
            .tabViewStyle(.page)
            .navigationTitle {
                NavTitle(title, color: routineColor)
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
                RoutineName(routine: routine)
                RoutineImage(routine: routine)
                FormColorPicker(color: $color)
                RoutineExercises(routine: routine)
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
    }
}
