//
//  ActionButton.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct ActionButton: View {
    // MARK: - Parameters

    private var action: () -> Void
    private var imageSystemName: String // "arrow.backward"
    private var buttonText: String? // "Previous"
    private var tint: Color
    private var onLongPress: (() -> Void)?

    public init(action: @escaping () -> Void,
                imageSystemName: String,
                buttonText: String? = nil,
                tint: Color,
                onLongPress: (() -> Void)? = nil)
    {
        self.action = action
        self.imageSystemName = imageSystemName
        self.buttonText = buttonText
        self.tint = tint
        self.onLongPress = onLongPress
    }

    // MARK: - Locals

    #if os(iOS)
        let imageScaleFactor = 0.7
    #endif

    // MARK: - Views

    public var body: some View {
        VStack {
            buttonBody

            if let _text = buttonText {
                Text(_text)
                    .lineLimit(1)
            }
        }
    }

    private var buttonBody: some View {
        #if os(watchOS)
            button
                .foregroundStyle(.tint)
                .tint(tint)
                .font(.title)
                .fontWeight(.bold)
        #elseif os(iOS)
            ZStack {
                Capsule(style: .circular)
                    .foregroundStyle(tint.opacity(0.2))
                button
                    .foregroundStyle(tint)
                    .fontWeight(.bold)
            }
        #endif
    }

    private var label: some View {
        #if os(watchOS)
            Image(systemName: imageSystemName)
                .symbolRenderingMode(.hierarchical)
        #elseif os(iOS)
            Image(systemName: imageSystemName)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .scaleEffect(imageScaleFactor)
        #endif
    }

    @ViewBuilder
    private var button: some View {
        if onLongPress != nil {
            longPressButton
        } else {
            normalButton
        }
    }

    private var normalButton: some View {
        Button(action: action, label: { label })
    }

    private var longPressButton: some View {
        Button(action: {}, label: { label })
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        onLongPress?()
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        action()
                    }
            )
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ActionButton(action: {}, imageSystemName: "arrow.backward", buttonText: "Previous", tint: .green)
                .frame(width: 300, height: 200)
            ActionButton(action: {}, imageSystemName: "checkmark", buttonText: "Done", tint: .blue)
                .frame(width: 300, height: 200)
            ActionButton(action: {}, imageSystemName: "xmark", buttonText: "Stop", tint: .red)
                .frame(width: 100, height: 66)
        }
    }
}
