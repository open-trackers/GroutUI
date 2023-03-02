//
//  ElapsedTimeText.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Compactor

import GroutLib
import TrackerLib

public struct ElapsedTimeText: View {
    // MARK: - Parameters

    private let elapsedSecs: TimeInterval
    private let timeElapsedFormat: TimeElapsedFormat

    public init(elapsedSecs: TimeInterval, timeElapsedFormat: TimeElapsedFormat = .hh_mm_ss) {
        self.elapsedSecs = elapsedSecs
        self.timeElapsedFormat = timeElapsedFormat

        let compactorStyle: TimeCompactor.Style = {
            switch timeElapsedFormat {
            case .hh_mm:
                return .short
            case .hh_mm_ss:
                return .medium
            case .mm_ss:
                return .short
            }
        }()

        tc = TimeCompactor(ifZero: "", style: compactorStyle, roundSmallToWhole: false)
    }

    // MARK: - Locals

    private var tc: TimeCompactor

    // MARK: - Views

    public var body: some View {
        Text("\(getFormatElapsed(elapsedSecs))")
            .modify {
                if #available(iOS 16.1, watchOS 9.1, *) {
                    $0.fontDesign(.monospaced)
                } else {
                    $0.monospaced()
                }
            }
    }

    private func getFormatElapsed(_ timeInterval: TimeInterval?) -> String {
        guard let timeInterval else { return "??:??:??" }
        return formatElapsed(timeInterval: timeInterval, timeElapsedFormat: timeElapsedFormat)
            ?? tc.string(from: timeInterval as NSNumber)
            ?? ""
    }
}

struct ElapsedTimeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Section("hh:mm:ss") {
                ElapsedTimeText(elapsedSecs: 0, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 40000, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 86399, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 86400, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 234_232, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 86400 * 365, timeElapsedFormat: .hh_mm_ss)
                ElapsedTimeText(elapsedSecs: 216_234_232, timeElapsedFormat: .hh_mm_ss)
            }

            Divider()

            Section("hh:mm") {
                ElapsedTimeText(elapsedSecs: 0, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 40000, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 86399, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 86400, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 234_232, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 86400 * 365, timeElapsedFormat: .hh_mm)
                ElapsedTimeText(elapsedSecs: 216_234_232, timeElapsedFormat: .hh_mm)
            }

            Divider()
            Section("mm:ss") {
                ElapsedTimeText(elapsedSecs: 3599, timeElapsedFormat: .mm_ss)
                ElapsedTimeText(elapsedSecs: 3600, timeElapsedFormat: .mm_ss)
            }
        }
    }
}
