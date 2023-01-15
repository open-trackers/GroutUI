//
//  NumberImage.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib

public struct NumberImage: View {
    // MARK: - Parameters

    private var value: Int16
    private var isCircle: Bool
    private var disabled: Bool

    public init(_ value: Int16, isCircle: Bool, disabled: Bool = false) {
        self.value = value
        self.isCircle = isCircle
        self.disabled = disabled
    }

    // MARK: - Views

    public var body: some View {
        let prefix = systemImagePrefix(Int(value))
        let shape = isCircle ? "circle" : "square"
        let full = "\(prefix).\(shape).fill"

        return ZStack {
            Image(systemName: "\(shape).fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(tintColor)
            Image(systemName: full)
                .resizable()
                .scaledToFit()
                .foregroundColor(.black.opacity(0.5))
        }
        .compositingGroup()
    }

    private var tintColor: Color {
        disabled ? disabledColor : .white
    }
}

struct NumberImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NumberImage(120, isCircle: true)
        }
    }
}
