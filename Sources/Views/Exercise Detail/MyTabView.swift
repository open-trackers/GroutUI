//
//  MyTabView.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

#if os(watchOS)

struct MyTabView<Tabs: View>: View {
    
    @Binding var selection: Int
    @ViewBuilder let tabs: () -> Tabs

    var body: some View {
        TabView(selection: $selection) {
            tabs()
        }
        .tabViewStyle(.page)
    }
    
}

struct MyTabItem<Content: View>: View {
    
    @Binding var selection: Int
    let tagNo: Int
    var content: () -> Content
    
    var body: some View {
        VStack {
            Form {
                content()
            }
            .frame(maxHeight: .infinity)

            HStack {
                Button(action: previousTabAction) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                Spacer()
                Button(action: nextTabAction) {
                    Image(systemName: "arrow.right.circle.fill")
                }
            }
            .imageScale(.large)
            .padding(.horizontal, 20)
            .buttonStyle(.plain)
            .foregroundStyle(.green)
            .padding(.bottom)
        }
        .tag(tagNo)
        // .border(.primary.opacity(0.2))
        .ignoresSafeArea(.all, edges: [.bottom])

    }
    private func previousTabAction() {
        if selection == 0 { selection = 8 } else {
            selection -= 1
        }
    }

    private func nextTabAction() {
        if selection == 8 { selection = 0 } else {
            selection += 1
        }
    }
}

#endif

//struct MyTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyTabView()
//    }
//}
