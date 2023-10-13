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
import TrackerUI

public struct ExerciseRun: View {
    @EnvironmentObject private var manager: CoreDataStack

    @AppStorage(logToHistoryKey) var logToHistory: Bool = true

    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @Environment(\.colorScheme) private var colorScheme
    #endif

    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage(alwaysAdvanceOnLongPressKey) var alwaysAdvanceOnLongPress: Bool = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: ExerciseRun.self))

    // MARK: - Parameters

    @ObservedObject private var exercise: Exercise
    private let routineStartedAt: Date
    private var onNextIncomplete: (Int16?) -> Void
    private var hasNextIncomplete: () -> Bool
    private var onEdit: (URL) -> Void

    public init(exercise: Exercise,
                routineStartedAt: Date,
                onNextIncomplete: @escaping (Int16?) -> Void,
                hasNextIncomplete: @escaping () -> Bool,
                onEdit: @escaping (URL) -> Void)
    {
        self.exercise = exercise
        self.routineStartedAt = routineStartedAt
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

    #if os(watchOS)
        private let maxFontSize: CGFloat = 60
    #elseif os(iOS)
        private let maxFontSize: CGFloat = 80
    #endif

    // MARK: - Views

    public var body: some View {
        platformContent
            .onDisappear {
                shortPressDone = false // to avoid double presses
            }
            // NOTE: using an alert, as confirmationDialog may be clipped at top of view on iPad
            // .confirmationDialog(
            .alert("Long Press",
                   isPresented: $showAdvanceAlert)
        {
            Button("Remain at \(exercise.formattedIntensity(exercise.lastIntensity, withUnits: true))") {
                markDone(withAdvance: false)
            }
            Button("Advance to \(exercise.formattedIntensity(exercise.advancedIntensity, withUnits: true))") {
                markDone(withAdvance: true)
            }
            Button("Always advance on long press") {
                alwaysAdvanceOnLongPress = true
                markDone(withAdvance: true)
            }
            Button(role: .cancel) {
                shortPressDone = false
            } label: {
                Text("Cancel")
            }
        }
    }

    #if os(iOS)
        private let slices: CGFloat = 5
    #elseif os(watchOS)
        private let slices: CGFloat = 14
    #endif

    #if os(watchOS)
        private var platformContent: some View {
            GeometryReader { geo in
                VStack {
                    titleText
                        .frame(height: geo.size.height * 3 / slices)

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
                    .frame(height: geo.size.height * 5 / slices)

                    navigationRow
                        .frame(height: geo.size.height * 6 / slices)
                }
            }
        }
    #endif

    #if os(iOS)
        private var platformContent: some View {
            GeometryReader { geo in
                let isPortrait = geo.size.height > geo.size.width
                VStack {
                    titleText
                        .frame(maxHeight: geo.size.height / slices)
                    Group {
                        if isPortrait {
                            HStack(alignment: .top) {
                                settings
                                volume
                            }
                            intensity
                        } else {
                            HStack(alignment: .top) {
                                settings
                                volume
                                intensity
                                    .frame(width: geo.size.width * 2 / slices)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    navigationRow
                        .padding(.top)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // allow space for index indicator
            }
        }
    #endif

    private var settings: some View {
        ExerciseRunSettings(exercise: exercise, labelFont: labelFont, onEdit: onEdit) {
            #if os(watchOS)
                Haptics.play()
                middleMode = middleMode.next
            #endif
        }
    }

    private var volume: some View {
        ExerciseRunVolume(exercise: exercise, labelFont: labelFont, onEdit: onEdit) {
            #if os(watchOS)
                Haptics.play()
                middleMode = middleMode.next
            #endif
        }
    }

    private var intensity: some View {
        ExerciseRunIntensity(exercise: exercise, labelFont: labelFont) {
            #if os(watchOS)
                Haptics.play()
                middleMode = middleMode.next
            #endif
        }
    }

    private var navigationRow: some View {
        HStack {
            ActionButton(onShortPress: isDone ? undoAction : doneAction,
                         imageSystemName: isDone ? "arrow.uturn.backward" : "checkmark",
                         buttonText: isDone ? "Undo" : "Done",
                         labelFont: labelFont,
                         tint: shortPressDone ? disabledColor : (isDone ? exerciseUndoColor : exerciseDoneColor),
                         onLongPress: isDone ? nil : doneLongPressAction)
                .disabled(shortPressDone)

            ActionButton(onShortPress: nextAction,
                         imageSystemName: "arrow.forward",
                         buttonText: "Next",
                         labelFont: labelFont,
                         tint: nextColor,
                         onLongPress: nil)
                .disabled(!hasNext)
        }
    }

    private var titleText: some View {
        TitleText(exercise.wrappedName, maxFontSize: maxFontSize)
            .foregroundColor(titleColor)
    }

    // MARK: - Properties

    // NOTE: mirrored in RoutineControl
    private var labelFont: Font {
        #if os(watchOS)
            .body
        #elseif os(iOS)
            if horizontalSizeClass == .regular, verticalSizeClass == .regular {
                return .largeTitle
            } else {
                return .title2
            }
        #endif
    }

    private var titleColor: Color {
        #if os(watchOS)
            let base = exerciseColorDarkBg
        #elseif os(iOS)
            let base = colorScheme == .light ? .primary : exerciseColorDarkBg
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

    // MARK: - Actions

    private func nextIncompleteAction() {
        logger.debug("\(#function) \(exercise.wrappedName) userOrder=\(exercise.userOrder) uri=\(exercise.uriRepresentationSuffix ?? "")")

        // NOTE: no haptic should be done here, as it's secondary to other actions

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onNextIncomplete(exercise.userOrder)
        }
    }

    private func nextAction() {
        Haptics.play()
        nextIncompleteAction()
    }

    private func undoAction() {
        logger.debug("\(#function)")
        Haptics.play()
        exercise.lastCompletedAt = nil
    }

    private func doneAction() {
        shortPressDone = true // to avoid double presses
        markDone(withAdvance: false)
    }

    private func doneLongPressAction() {
        shortPressDone = true // to avoid double presses

        logger.debug("\(#function)")
        if alwaysAdvanceOnLongPress {
            markDone(withAdvance: true)
        } else {
            Haptics.play(.warning)
            showAdvanceAlert = true
        }
    }

    // MARK: - Helpers

    private func markDone(withAdvance: Bool) {
        logger.debug("\(#function): withAdvance=\(withAdvance)")

        Haptics.play(withAdvance ? .immediateAction : .click)

        guard let mainStore = manager.getMainStore(viewContext) else { return }

        do {
            try exercise.markDone(viewContext,
                                  mainStore: mainStore,
                                  withAdvance: withAdvance,
                                  routineStartedAt: routineStartedAt,
                                  logToHistory: logToHistory)
            try viewContext.save()

        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }

        nextIncompleteAction()
    }
}

struct ExerciseRun_Previews: PreviewProvider {
    struct TestHolder: View {
        var exercise: Exercise
        var body: some View {
            ExerciseRun(exercise: exercise,
                        routineStartedAt: Date.now,
                        onNextIncomplete: { _ in },
                        hasNextIncomplete: { true },
                        onEdit: { _ in })
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = Exercise.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.primarySetting = 4
        e1.intensityStep = 8.2
        e1.units = Units.minutes.rawValue
        // try? ctx.save()
        return NavigationStack {
            TestHolder(exercise: e1)
                .accentColor(.orange)
        }
    }
}
