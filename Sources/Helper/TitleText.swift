//
//  TitleText.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct TitleText: View {
    @Environment(\.colorScheme) private var colorScheme

    private var text: String

    public init(_ text: String) {
        self.text = text
    }

    private let titleWeight: Font.Weight = .medium

    public var body: some View {
        Text(text)
            .font(.system(size: 200))
            .minimumScaleFactor(0.1)
            .fontWeight(titleWeight)
            // .shadow(color: shadowColor, radius: 0.5, x: 0.5, y: 0.5)
            .allowsTightening(true)
            .lineLimit(1)
    }

//    private var shadowColor: Color {
//        colorScheme == .light ? .black.opacity(0.33) : .clear
//    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().strokeBorder(Color.red, lineWidth: 10)
            TitleText("This is a test")
                .foregroundStyle(.orange)
        }
    }
}
