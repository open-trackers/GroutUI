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

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "AddRoutineButton"
)

public struct AddRoutineButton<Label>: View
    where Label: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: MyRouter

    // MARK: - Parameters

    private var label: () -> Label

    public init(label: @escaping () -> Label) {
        self.label = label
    }

    // MARK: - Locals

    @FetchRequest(entity: Routine.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Routine.userOrder, ascending: true)],
                  animation: .default)
    private var routines: FetchedResults<Routine>

    // MARK: - Views

    public var body: some View {
        Button(action: addAction, label: label)
    }

    // MARK: - Properties

    private var maxOrder: Int16 {
        routines.last?.userOrder ?? 0
    }

    // MARK: - Actions

    private func addAction() {
        withAnimation {
            let nu = Routine.create(viewContext, userOrder: maxOrder + 1)
            nu.name = "New Routine"
            do {
                try PersistenceManager.shared.save(forced: true)
                router.path.append(MyRoutes.routineDetail(nu.uriRepresentation))
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
        }
    }
}

struct AddRoutineButton_Previews: PreviewProvider {
    static var previews: some View {
        AddRoutineButton {
            Text("Add Routine")
        }
    }
}
