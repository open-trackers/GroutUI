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

public struct RoutineControl: View {
    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

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

    // MARK: - Views

    public var body: some View {
        GeometryReader { geo in
            #if os(watchOS)
                innerBody(geo)
            #elseif os(iOS)
                innerBody(geo, heightFactor: heightFactor)
                    // NOTE padding needed on iPhone 8, 12, and possibly others (visible in light mode)
                    .padding(.horizontal)
            #endif
        }
    }

    private func innerBody(_ geo: GeometryProxy, heightFactor: CGFloat = 1.0) -> some View {
        VStack(spacing: 9) {
            top
                .frame(height: geo.size.height * 3 / 13 * heightFactor)
            middle
                .frame(height: geo.size.height * 5 / 13 * heightFactor)
            bottom
                .frame(height: geo.size.height * 5 / 13 * heightFactor)
        }
    }

    private var top: some View {
        TitleText(routine.wrappedName)
            .foregroundColor(titleColor)
    }

    private var middle: some View {
        HStack(alignment: .bottom) {
            ActionButton(action: onStop,
                         imageSystemName: "xmark",
                         buttonText: "Stop",
                         tint: stopColor,
                         onLongPress: nil)
            ElapsedSinceView(startedAt: startedAt)
        }
    }

    private var bottom: some View {
        HStack(alignment: .bottom) {
            ActionButton(action: onAdd,
                         imageSystemName: "plus", // plus.circle.fill
                         buttonText: "Add",
                         tint: exerciseColor,
                         onLongPress: nil)
            ActionButton(action: { onNextIncomplete(nil) },
                         imageSystemName: "arrow.forward",
                         buttonText: "Next",
                         tint: onNextIncompleteColor,
                         onLongPress: nil)
                .disabled(!hasRemaining)
        }
    }

    // MARK: - Properties

    #if os(iOS)
        private var heightFactor: CGFloat {
            verticalSizeClass == .regular ? 0.6 : 0.8
        }
    #endif

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
        let ctx = PersistenceManager.getPreviewContainer().viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Leg"
        let e1 = Exercise.create(ctx, userOrder: 0)
        e1.name = "Lat Pulldown"
        e1.routine = routine
        return NavigationStack {
            TestHolder(routine: routine)
        }
    }
}
