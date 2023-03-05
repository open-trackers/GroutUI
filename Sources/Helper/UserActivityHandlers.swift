//
//  UserActivityHandlers.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

import GroutLib

public extension Notification.Name {
    static let startRoutine = Notification.Name("grout-start-routine") // payload of routineURI
}

public func handleStartRoutineUA(_ context: NSManagedObjectContext, _ userActivity: NSUserActivity) {
    guard let routineURI = userActivity.userInfo?[userActivity_uriRepKey] as? URL,
          let routine = Routine.get(context, forURIRepresentation: routineURI) as? Routine,
          !routine.isDeleted,
          routine.archiveID != nil
    else {
        // logger.notice("\(#function): could not resolve Routine; so unable to start it via shortcut.")
        return
    }

    // logger.notice("\(#function): routine=\(routine.wrappedName)")

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        NotificationCenter.default.post(name: .startRoutine, object: routineURI)
    }
}
