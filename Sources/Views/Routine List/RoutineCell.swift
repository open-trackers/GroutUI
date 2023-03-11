//
//  RoutineCell.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

import Compactor

import GroutLib
import TrackerLib
import TrackerUI

extension Routine: Celled {}

public struct RoutineCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    private var routine: Routine
    @Binding private var now: Date
    private let onDetail: (URL) -> Void
    private var onShortPress: (URL) -> Void

    public init(routine: Routine,
                now: Binding<Date>,
                onDetail: @escaping (URL) -> Void,
                onShortPress: @escaping (URL) -> Void)
    {
        self.routine = routine
        _now = now
        self.onDetail = onDetail
        self.onShortPress = onShortPress
    }

    // MARK: - Views

    public var body: some View {
        // NOTE: onShortPress true to clear lastCompleted in each Exercise
        Cell(element: routine,
             now: $now,
             defaultImageName: "dumbbell.fill",
             subtitle: subtitle,
             onDetail: { onDetail(uri) },
             onShortPress: { onShortPress(uri) })
    }

    private func subtitle() -> some View {
        SinceText(startedAt: routine.lastStartedAt ?? Date(), duration: routine.lastDuration, now: $now, compactorStyle: compactorStyle)
    }

    // MARK: - Properties

    private var uri: URL {
        routine.uriRepresentation
    }

    private var compactorStyle: TimeCompactor.Style {
        #if os(watchOS)
            .short
        #else
            .full
        #endif
    }
}

struct RoutineCell_Previews: PreviewProvider {
    struct TestHolder: View {
        var routines: [Routine]
        @State var now: Date = .now
        var body: some View {
            List(routines, id: \.self) { routine in
                RoutineCell(routine: routine, now: $now, onDetail: { _ in }, onShortPress: { _ in })
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let r1 = Routine.create(ctx, userOrder: 0)
        r1.name = "Pull" // "Back & Bicep"
        r1.lastDuration = 3545
        r1.lastStartedAt = Date.now.addingTimeInterval(-364 * 86400)
        let r2 = Routine.create(ctx, userOrder: 0)
        r2.name = "Push" // "Back & Bicep"
        return NavigationStack {
            TestHolder(routines: [r1, r2])
                .environment(\.managedObjectContext, ctx)
        }
        .environment(\.managedObjectContext, ctx)
    }
}
