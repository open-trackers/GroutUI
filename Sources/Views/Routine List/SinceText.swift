//
//  SinceText.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import SwiftUI

import Compactor

import GroutLib

public struct SinceText: View {
    // MARK: - Parameters

    private var startedAt: Date
    private var duration: TimeInterval
    @Binding private var now: Date
    private var compactorStyle: TimeCompactor.Style

    public init(startedAt: Date, duration: TimeInterval, now: Binding<Date>, compactorStyle: TimeCompactor.Style) {
        self.startedAt = startedAt
        self.duration = duration
        _now = now
        self.compactorStyle = compactorStyle

        tcDur = .init(ifZero: "", style: compactorStyle, roundSmallToWhole: false)
        tcSince = .init(ifZero: nil, style: compactorStyle, roundSmallToWhole: true)
    }

    // MARK: - Locals

    private var tcDur: TimeCompactor
    private var tcSince: TimeCompactor

    // MARK: - Views

    public var body: some View {
        VStack {
            if let _lastStr = lastStr {
                Text(_lastStr)
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Properties

    private var lastStr: String? {
        guard let _sinceStr = sinceStr,
              let _durationStr = durationStr
        else { return nil }
        return "\(_sinceStr) ago, for \(_durationStr)"
    }

    // time interval since the last workout ended, formatted compactly
    private var sinceStr: String? {
        guard duration > 0
        else { return nil }
        let since = max(0, now.timeIntervalSince(startedAt) - duration)
        return tcSince.string(from: since as NSNumber)
    }

    private var durationStr: String? {
        tcDur.string(from: duration as NSNumber)
    }
}

struct SinceText_Previews: PreviewProvider {
    struct TestHolder: View {
        var startedAt = Date.now.addingTimeInterval(-2 * 86400)
        var duration = 1000.0
        @State var now: Date = .now
        var body: some View {
            SinceText(startedAt: startedAt, duration: duration, now: $now, compactorStyle: .short)
        }
    }

    static var previews: some View {
        let ctx = PersistenceManager.preview.container.viewContext
        return NavigationStack {
            TestHolder()
                .environment(\.managedObjectContext, ctx)
        }
        .environment(\.managedObjectContext, ctx)
    }
}
