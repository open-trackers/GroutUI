//
//  MyTabControl.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

#if os(watchOS)

    protocol Tabable: RawRepresentable where RawValue == Int {
        static var first: Self { get }
        static var last: Self { get }
        var next: Self? { get }
        var previous: Self? { get }
    }

    struct MyTabControl<T: Tabable>: View {
        @Binding var selectedTab: T
        var tint: Color

        var body: some View {
            HStack {
                Button(action: {
                    guard let previous = selectedTab.previous else { return }
                    selectedTab = previous
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                .foregroundStyle(tint)
                .disabled(selectedTab == T.first)
                
                
                Spacer()
                
                Text("\(selectedTab.rawValue) of \(T.last.rawValue)")
                
                Spacer()
                
                Button(action: {
                    guard let next = selectedTab.next else { return }
                    selectedTab = next
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundStyle(tint)
                .disabled(selectedTab == T.last)
            }
            .imageScale(.large)
            .padding(.horizontal, 20)
            .buttonStyle(.plain)
            .padding(.bottom)
        }
    }
#endif

// struct MyTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyTabView()
//    }
// }
