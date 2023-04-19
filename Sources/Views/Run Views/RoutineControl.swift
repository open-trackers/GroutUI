//
//  RoutineControl.swift
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

public struct RoutineControl: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    // MARK: - Parameters

    private var routine: Routine
    private let onAdd: () -> Void
    private let onStop: () -> Void
    private let onNextIncomplete: (Int16?) -> Void
    private var onRemainingCount: () -> Int
    private var startedAt: Date

    public init(routine: Routine,
                onAdd: @escaping () -> Void,
                onStop: @escaping () -> Void,
                onNextIncomplete: @escaping (Int16?) -> Void,
                onRemainingCount: @escaping () -> Int,
                startedAt: Date)
    {
        self.routine = routine
        self.onAdd = onAdd
        self.onStop = onStop
        self.onNextIncomplete = onNextIncomplete
        self.onRemainingCount = onRemainingCount
        self.startedAt = startedAt
    }

    // MARK: - Locals

    #if os(watchOS)
        let verticalSpacing: CGFloat = 10
        let minTitleHeight: CGFloat = 20
        let horzButtonSpacing: CGFloat = 15
        let maxFontSize: CGFloat = 35
    #elseif os(iOS)
        let verticalSpacing: CGFloat = 30
        let minTitleHeight: CGFloat = 60
        let maxButtonHeight: CGFloat = 150
        let horzButtonSpacing: CGFloat = 30
        let maxFontSize: CGFloat = 40
    #endif

    // MARK: - Views

    public var body: some View {
        platformView
    }

    #if os(watchOS)
        private var platformView: some View {
            GeometryReader { geo in
                VStack(spacing: verticalSpacing) {
                    TitleText(routine.wrappedName, maxFontSize: maxFontSize)
                        .foregroundColor(titleColor)
                        .frame(minHeight: minTitleHeight)
                        .frame(height: geo.size.height * 1 / 5)

                    middle
                        .frame(height: geo.size.height * 2 / 5)

                    bottom
                        .frame(height: geo.size.height * 2 / 5)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            VStack(spacing: verticalSpacing) {
                TitleText(routine.wrappedName, maxFontSize: maxFontSize)
                    .foregroundColor(titleColor)
                    .frame(minHeight: minTitleHeight)
                Group {
                    middle

                    bottom
                }
                .frame(maxHeight: maxButtonHeight)
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            // NOTE: padding needed on iPhone 8, 12, and possibly others (visible in light mode)
            .padding(.horizontal)
        }
    #endif

    private var middle: some View {
        HStack(alignment: .bottom, spacing: horzButtonSpacing) {
            ActionButton(onShortPress: onStop,
                         imageSystemName: "xmark",
                         buttonText: "Stop",
                         labelFont: labelFont,
                         tint: stopColor,
                         onLongPress: nil)
            ElapsedView(startedAt: startedAt,
                        labelFont: labelFont,
                        tint: routineColor)
        }
    }

    private var bottom: some View {
        HStack(alignment: .bottom, spacing: horzButtonSpacing) {
            ActionButton(onShortPress: onAdd,
                         imageSystemName: "plus", // plus.circle.fill
                         buttonText: "Add",
                         labelFont: labelFont,
                         tint: exerciseColorDarkBg,
                         onLongPress: nil)
            ActionButton(onShortPress: { onNextIncomplete(nil) },
                         imageSystemName: "arrow.forward",
                         buttonText: "Next",
                         labelFont: labelFont,
                         tint: onNextIncompleteColor,
                         onLongPress: nil)
                .disabled(!hasRemaining)
        }
    }

    // MARK: - Properties

    // NOTE: mirrored in ExerciseRun
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

    private var onNextIncompleteColor: Color {
        hasRemaining ? exerciseNextColor : disabledColor
    }

    private var hasRemaining: Bool {
        onRemainingCount() > 0
    }
}

struct RoutineControl_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        @State var selectedTab: URL? = .init(string: "blah")!
        var startedAt = Date.now.addingTimeInterval(-1200)
        var body: some View {
            RoutineControl(routine: routine,
                           onAdd: {},
                           onStop: {},
                           onNextIncomplete: { _ in },
                           onRemainingCount: { 3 },
                           startedAt: startedAt)
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Chest"
        let e1 = Exercise.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        // try? ctx.save()
        return NavigationStack {
            TestHolder(routine: routine)
                .accentColor(.orange)
        }
    }
}
