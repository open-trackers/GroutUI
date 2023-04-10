//
//  WidgetView.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import WidgetKit

import Compactor

import GroutLib

public struct WidgetView: View {
    // MARK: - Parameters

    private let entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    // MARK: - Locals

    private static let tc = NumberCompactor(ifZero: "0", roundSmallToWhole: true)

    // MARK: - Views

    public var body: some View {
        #if os(watchOS)
            gauge
        #elseif os(iOS)
            Section {
                gauge
            } header: {
                Text("Daily Calories")
                    .foregroundColor(.secondary)
            }
        #endif
    }

    private var gauge: some View {
        Gauge(value: percent, in: 0.0 ... 1.0) {
            Text("CAL")
            // .foregroundColor(isOver ? .red : .primary)
        } currentValueLabel: {
            Text(caloriesStr)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(Gradient(colors: colors))
    }

    // MARK: - Properties

    private var caloriesStr: String {
        "X"
        // Self.tc.string(from: entry.currentCalories as NSNumber) ?? ""
    }

    private var colors: [Color] {
        let c = entry.pairs.map(\.color)
        return c.first == nil ? [.accentColor] : c
    }

//    private var remaining: Int {
//        entry.timeInterval - entry.currentCalories // may be negative
//    }

//    private var isOver: Bool {
//        entry.timeInterval < entry.currentCalories
//    }

    private var percent: Float {
        0.1
//        guard entry.timeInterval > 0 else { return 0 }
//        return Float(entry.currentCalories) / Float(entry.timeInterval)
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(timeInterval: 2000)
        return WidgetView(entry: entry)
            .accentColor(.blue)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
