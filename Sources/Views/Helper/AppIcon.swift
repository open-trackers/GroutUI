//
//  AppIcon.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct AppIcon: View {
    let name: String

    public init(name: String) {
        self.name = name
    }

    public var body: some View {
        if let img = UIImage(named: name) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else {
            // in case the AppIcon has been stripped from the bundle
            Image(systemName: "info.circle")
                .resizable()
        }
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon(name: "grt_icon")
    }
}
