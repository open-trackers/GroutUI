//
//  WidgetView.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Compactor
import SwiftUI

import GroutLib
import TrackerUI

public struct WidgetView: View {
    @Environment(\.colorScheme) private var colorScheme

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

    private static let tc = TimeCompactor(ifZero: nil, style: Self.style)

    // MARK: - Views

    public var body: some View {
        platformView
    }

    private var cellForeground: Color {
        .primary.opacity(colorScheme == .light ? 0.8 : 1.0)
    }

    #if os(watchOS)
        private var platformView: some View {
            VStack {
                Image(systemName: entry.imageName ?? defaultImageName)
                Text(sinceStr)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CellBackground(color: entry.color))
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            VStack(alignment: .leading, spacing: 15) {
                Image(systemName: entry.imageName ?? defaultImageName)
                    .imageScale(.large)
                Spacer()
                TitleText(entry.name, lineLimit: 2)
                Spacer()
                Text("\(sinceStr) ago")
                    .font(.body)
                    .italic()
                    .opacity(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(cellForeground)
            .background(CellBackground(color: entry.color))
        }
    #endif

    private var cellBackground: some View {
        CellBackground(color: entry.color)
    }

    // MARK: - Properties

    private var sinceStr: String {
        Self.tc.string(from: entry.timeInterval as NSNumber) ?? ""
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(name: "Back & Bicep", imageName: nil, timeInterval: 2000, color: .orange)
        return WidgetView(entry: entry)
            .accentColor(.blue)
        // .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
