//
//  EntityBackground.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct EntityBackground: View {
    private let color: Color

    public init(_ color: Color) {
        self.color = color
    }

    public var body: some View {
        LinearGradient(gradient: .init(colors: [
            color.opacity(0.1),
            color.opacity(0.2),
        ]),
        startPoint: .topLeading,
        endPoint: .bottom)
    }
}

struct EntityBackground_Previews: PreviewProvider {
    static var previews: some View {
        EntityBackground(.blue)
    }
}
