//
//  AddRoutineButton.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

public struct AddRoutineButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    public init() {}

    // MARK: - Locals

    // MARK: - Views

    public var body: some View {
        AddElementButton(elementName: "Routine",
                         onCreate: createAction,
                         onAfterSave: afterSaveAction)
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        do {
            return try Routine.maxUserOrder(viewContext) ?? 0
        } catch {
            // logger.error("\(#function): \(error.localizedDescription)")
        }
        return 0
    }

    // MARK: - Actions

    private func createAction() -> Routine {
        let nu = Routine.create(viewContext, userOrder: maxOrder)
        nu.name = "New Routine"
        nu.userOrder = maxOrder + 1
        return nu
    }

    private func afterSaveAction(_ nu: Routine) {
        router.path.append(GroutRoute.routineDetail(nu.uriRepresentation))
    }
}

// struct AddRoutineButton_Previews: PreviewProvider {
//    static var previews: some View {
//        AddRoutineButton()
//    }
// }
