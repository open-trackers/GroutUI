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

    #if os(watchOS)
        private static let style: TimeCompactor.Style = .short
    #elseif os(iOS)
        private static let style: TimeCompactor.Style = .medium
    #endif

    private static let tc = TimeCompactor(ifZero: "", style: Self.style)

    // MARK: - Views

    public var body: some View {
        #if os(watchOS)
            gauge
        #elseif os(iOS)
            VStack {
                Section {
                    gauge
                } header: {
                    Text("Last routine")
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
        #endif
    }

    private var gauge: some View {
        ZStack {
            Text(sinceStr)
                .foregroundColor(.primary)
            Circle()
                .strokeBorder(Gradient(colors: colors), lineWidth: 5)
        }
        .tint(Gradient(colors: colors))
    }

    // MARK: - Properties

    private var sinceStr: String {
        Self.tc.string(from: entry.timeInterval as NSNumber) ?? ""
    }

    private var colors: [Color] {
        let c = entry.pairs.map(\.color)
        return c.first == nil ? [.accentColor] : c
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
