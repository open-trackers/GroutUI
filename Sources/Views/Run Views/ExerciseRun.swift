//
//  ExerciseRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import GroutLib

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ExerciseRun"
)

public struct ExerciseRun: View {
    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.colorScheme) private var colorScheme
    #endif

    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage(alwaysAdvanceOnLongPressKey) var alwaysAdvanceOnLongPress: Bool = false

    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise
    private var onNextIncomplete: (Int16?) -> Void
    private var hasNextIncomplete: () -> Bool
    private var onEdit: (URL) -> Void

    public init(exercise: Exercise,
                onNextIncomplete: @escaping (Int16?) -> Void,
                hasNextIncomplete: @escaping () -> Bool,
                onEdit: @escaping (URL) -> Void)
    {
        self.exercise = exercise
        self.onNextIncomplete = onNextIncomplete
        self.hasNextIncomplete = hasNextIncomplete
        self.onEdit = onEdit
    }

    // MARK: - Locals

    @State private var showAdvanceAlert = false

    // used to avoid double presses
    @State private var shortPressDone = false

    #if os(watchOS)
        @SceneStorage("middle-mode") private var middleMode: ExerciseMiddleRowMode = .intensity
    #endif

    // MARK: - Views

    public var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                content
            }
            .onDisappear {
                shortPressDone = false // to avoid double presses
            }
            .alert("Long Press",
                   isPresented: $showAdvanceAlert,
                   actions: {
                       VStack {
                           Button("Yes, advance") { markDone(withAdvance: true) }
                           Button("No") { markDone(withAdvance: false) }
                           Button("Always advance") {
                               alwaysAdvanceOnLongPress = true
                               markDone(withAdvance: true)
                           }
                       }
                   },
                   message: {
                       Text(alertTitle)
                   })
        }
    }

    private var content: some View {
        GeometryReader { geo in
            #if os(watchOS)
                VStack {
                    titleText
                        .frame(height: geo.size.height * 3 / 13)

                    VStack {
                        switch middleMode {
                        case .intensity:
                            intensity
                        case .settings:
                            settings
                        case .volume:
                            volume
                        }
                    }
                    .frame(height: geo.size.height * 5 / 13)

                    navigationRow
                        .frame(height: geo.size.height * 5 / 13)
                }
            #elseif os(iOS)
                VStack {
                    titleText
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if verticalSizeClass == .regular {
                        HStack(alignment: .top) {
                            Group {
                                settings
                                volume
                            }
                            .frame(height: geo.size.height * 0.25)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        intensity
                            .frame(height: geo.size.height * 0.25)
                    } else {
                        HStack(alignment: .top) {
                            Group {
                                settings
                                volume
                                intensity
                                    .frame(width: geo.size.width * 0.4)
                            }
                            .frame(maxHeight: geo.size.height * 0.4)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    navigationRow
                        .frame(height: geo.size.height * 0.25)
                }
                // leave space at bottom for page indicator
                .padding(.bottom, geo.size.height / 10)
                .padding(.horizontal)
            #endif
        }
    }

    private var settings: some View {
        #if os(watchOS)
            ExerciseRunSettings(exercise: exercise, onEdit: onEdit, middleMode: $middleMode)
        #elseif os(iOS)
            ExerciseRunSettings(exercise: exercise, onEdit: onEdit)
        #endif
    }

    private var volume: some View {
        #if os(watchOS)
            ExerciseRunVolume(exercise: exercise, onEdit: onEdit, middleMode: $middleMode)
        #elseif os(iOS)
            ExerciseRunVolume(exercise: exercise, onEdit: onEdit)
        #endif
    }

    private var intensity: some View {
        #if os(watchOS)
            ExerciseRunIntensity(exercise: exercise, middleMode: $middleMode)
        #elseif os(iOS)
            ExerciseRunIntensity(exercise: exercise)
        #endif
    }

    private var navigationRow: some View {
        HStack {
            ActionButton(action: isDone ? undoAction : doneAction,
                         imageSystemName: isDone ? "arrow.uturn.backward" : "checkmark",
                         buttonText: isDone ? "Undo" : "Done",
                         tint: shortPressDone ? disabledColor : (isDone ? exerciseUndoColor : exerciseDoneColor),
                         onLongPress: isDone ? nil : doneLongPressAction)
                .disabled(shortPressDone)

            ActionButton(action: nextIncompleteAction,
                         imageSystemName: "arrow.forward",
                         buttonText: "Next",
                         tint: nextColor, onLongPress: nil)
                .disabled(!hasNext)
        }
    }

    private var titleText: some View {
        TitleText(exercise.wrappedName)
            .foregroundColor(titleColor)
    }

    // MARK: - Properties

    private var titleColor: Color {
        #if os(watchOS)
            let base = exerciseColor
        #elseif os(iOS)
            let base = colorScheme == .light ? .primary : exerciseColor
        #endif
        return isDone ? completedColor : base
    }

    private var isDone: Bool {
        exercise.isDone
    }

    private var advanceColor: Color {
        exercise.canAdvance ? exerciseAdvanceColor : disabledColor
    }

    private var hasNext: Bool {
        hasNextIncomplete()
    }

    private var nextColor: Color {
        hasNextIncomplete() ? exerciseNextColor : disabledColor
    }

    private var alertTitle: String {
        "Advance intensity from \(exercise.formatIntensity(exercise.lastIntensity)) to \(exercise.formatIntensity(exercise.advancedIntensity))?"
    }

    // MARK: - Actions

    private func nextIncompleteAction() {
        logger.debug("\(#function) \(exercise.wrappedName) userOrder=\(exercise.userOrder) uri=\(exercise.uriRepresentationSuffix ?? "")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onNextIncomplete(exercise.userOrder)
        }
    }

    private func doneAction() {
        shortPressDone = true // to avoid double presses

        logger.debug("\(#function)")
        markDone(withAdvance: false)
    }

    private func undoAction() {
        logger.debug("\(#function)")
        exercise.lastCompletedAt = nil
    }

    private func doneLongPressAction() {
        shortPressDone = true // to avoid double presses

        logger.debug("\(#function)")
        if alwaysAdvanceOnLongPress {
            markDone(withAdvance: true)
        } else {
            showAdvanceAlert = true
        }
    }

    // MARK: - Helpers

    private func markDone(withAdvance: Bool) {
        logger.debug("\(#function) withAdvance=\(withAdvance)")

        exercise.markDone(viewContext, withAdvance: withAdvance)

//        exercise.lastCompletedAt = now
//
//        if withAdvance {
//            exercise.lastIntensity = advancedIntensity
//        }

        // archive the run for charting
//        logRun(completedAt: now, intensity: self.intensity, now: now)

        nextIncompleteAction()
    }
}

struct ExerciseRun_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        var body: some View {
            ExerciseRun(exercise: exercise,
                        onNextIncomplete: { _ in },
                        hasNextIncomplete: { true },
                        onEdit: { _ in })
        }
    }

    static var previews: some View {
        let ctx = PersistenceManager.preview.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = Exercise.create(ctx, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.routine = routine
        e1.primarySetting = 4
        e1.intensityStep = 7.1
        return NavigationStack {
            TestHolder(exercise: e1)
        }
    }
}
