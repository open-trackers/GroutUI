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

    private let onShortPress: () -> Void
    private let imageSystemName: String // "arrow.backward"
    private let buttonText: String // "Previous"
    private let tint: Color
    private let onLongPress: (() -> Void)?

    public init(onShortPress: @escaping () -> Void,
                imageSystemName: String,
                buttonText: String,
                tint: Color,
                onLongPress: (() -> Void)? = nil)
    {
        self.onShortPress = onShortPress
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

            Text(buttonText)
                .lineLimit(1)
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
        Button(action: onShortPress, label: { label })
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
                        onShortPress()
                    }
            )
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ActionButton(onShortPress: {}, imageSystemName: "arrow.backward", buttonText: "Previous", tint: .green)
                .frame(width: 300, height: 200)
            ActionButton(onShortPress: {}, imageSystemName: "checkmark", buttonText: "Done", tint: .blue)
                .frame(width: 300, height: 200)
            ActionButton(onShortPress: {}, imageSystemName: "xmark", buttonText: "Stop", tint: .red)
                .frame(width: 100, height: 66)
        }
    }
}
