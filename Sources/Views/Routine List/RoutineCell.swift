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
    private var onShortPress: (URL, Bool) -> Void

    public init(routine: Routine,
                now: Binding<Date>,
                onDetail: @escaping (URL) -> Void,
                onShortPress: @escaping (URL, Bool) -> Void)
    {
        self.routine = routine
        _now = now
        self.onDetail = onDetail
        self.onShortPress = onShortPress
    }

    // MARK: - Views

    public var body: some View {
        // NOTE onShortPress true to clear lastCompleted in each Exercise
        Cell(element: routine,
             now: $now,
             defaultImageName: "dumbbell.fill",
             subtitle: subtitle,
             onDetail: { onDetail(uri) },
             onShortPress: { onShortPress(uri, true) })
//        GeometryReader { geo in
//            VStack(alignment: .leading, spacing: 0) {
//                topRow
//                    .frame(height: geo.size.height * 0.4)
//
//                bottomRow
//                    .frame(height: geo.size.height * 0.6)
//            }
//        }
//        .frame(minHeight: minHeight, maxHeight: .infinity)
//        .onAppear(perform: onAppearAction)
    }

//    private var topRow: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                HStack {
//                    Image(systemName: routine.imageName ?? "dumbbell.fill")
//                    Spacer()
//                }
//            }
//            .padding(.vertical, 12)
//            .contentShape(Rectangle())
//            .onTapGesture(perform: startAction)
//            // .border(.teal)
//
//            Spacer(minLength: 20)
//
//            detailButton
//            // .border(.teal)
//        }
//        .foregroundColor(routineColor)
//        .font(.title2)
//        .symbolRenderingMode(.hierarchical)
//    }
//
//    private var bottomRow: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                titleText
//                routineSinceText
//            }
//            Spacer()
//        }
//        .contentShape(Rectangle())
//        .onTapGesture(perform: startAction)
//        // .border(.teal)
//    }
//
//    private var detailButton: some View {
//        ZStack {
//            Image(systemName: "ellipsis")
//                .padding(.leading, 20)
//                .padding(.vertical, 18)
//
//            Button(action: detailAction) {
//                EmptyView()
//            }
//
//            .frame(width: 0, height: 0)
//            .foregroundColor(.clear)
//        }
//    }

//    private var titleText: some View {
//        TitleText(routine.name ?? "unknown")
//            .foregroundColor(titleColor)
//    }

    private func subtitle() -> some View {
        SinceText(startedAt: routine.lastStartedAt ?? Date(), duration: routine.lastDuration, now: $now, compactorStyle: compactorStyle)
            .font(.body)
            .italic()
            .foregroundColor(lastColor)
            .lineLimit(1)
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

//    // MARK: - Actions
//
//    private func detailAction() {
//        Haptics.play()
//
//        router.path.append(GroutRoute.routineDetail(routine.uriRepresentation))
//    }
//
//    // refresh immediately on routine completion (timer only updates 'now' on the minute)
//    private func onAppearAction() {
//        now = Date.now
//    }
//
//    private func startAction() {
//        Haptics.play(.startingAction)
//
//        // NOTE true to clear lastCompleted in each Exercise
//        onShortPress(routine.uriRepresentation, true)
//    }
}

struct RoutineCell_Previews: PreviewProvider {
    struct TestHolder: View {
        var routines: [Routine]
        @State var now: Date = .now
        var body: some View {
            List(routines, id: \.self) { routine in
                RoutineCell(routine: routine, now: $now, onDetail: { _ in }, onShortPress: { _, _ in })
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
