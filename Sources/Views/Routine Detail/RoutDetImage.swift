//
//  RoutDetImage.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import GroutLib
import TrackerUI

struct RoutDetImage: View {
    // MARK: - Parameters

    @ObservedObject var routine: Routine
    var forceFocus: Bool

    // MARK: - Views

    public var body: some View {
        Section {
            ImageStepper(initialName: routine.imageName,
                         imageNames: systemImageNames,
                         forceFocus: forceFocus)
            {
                routine.imageName = $0
            }
            #if os(watchOS)
            .imageScale(.small)
            #elseif os(iOS)
            .imageScale(.large)
            #endif
        } header: {
            Text("Image")
        }
    }

    // MARK: - Properties
}

struct RoutDetImage_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            Form {
                RoutDetImage(routine: routine, forceFocus: false)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Beverage"
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
            .accentColor(.orange)
    }
}
