//
//  BackgroundHandlers.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import GroutLib

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "BackgroundHandlers")

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

public func handleTaskAction(_ manager: CoreDataStack) async {
    logger.notice("\(#function) START")

    await manager.container.performBackgroundTask { backgroundContext in
        do {
            // TODO: phase these out
            try updateArchiveIDs(backgroundContext)
            try updateCreatedAts(backgroundContext)
            try backgroundContext.save()

            #if os(watchOS)
                // delete log records older than N days
                guard let keepSince = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
                else { throw TrackerError.missingData(msg: "Clean: could not resolve date one year in past") }
                logger.notice("\(#function): keepSince=\(keepSince)")
                try cleanLogRecords(backgroundContext, keepSince: keepSince)
                try backgroundContext.save()
            #endif

            #if os(iOS)
                guard let mainStore = manager.getMainStore(backgroundContext),
                      let archiveStore = manager.getArchiveStore(backgroundContext)
                else {
                    logger.error("\(#function): unable to acquire configuration to transfer log records.")
                    return
                }

                // move log records to archive store
                try transferToArchive(backgroundContext,
                                      mainStore: mainStore,
                                      archiveStore: archiveStore)
                try backgroundContext.save()
            #endif
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
    logger.notice("\(#function) END")
}
