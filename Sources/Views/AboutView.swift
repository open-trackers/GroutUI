//
//  AboutView.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct AboutView<IconImage>: View
    where IconImage: View
{
    private var websiteURL: URL
    private var privacyURL: URL?
    private var termsURL: URL?
    private var tutorialURL: URL?
    private var copyright: String?
    private var iconImage: () -> IconImage

    public init(websiteURL: URL,
                privacyURL: URL?,
                termsURL: URL?,
                tutorialURL: URL?,
                copyright: String?,
                iconImage: @escaping () -> IconImage)
    {
        self.websiteURL = websiteURL
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.tutorialURL = tutorialURL
        self.copyright = copyright
        self.iconImage = iconImage
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                iconImage()
                    .frame(width: 40, height: 40)

                VStack(spacing: 5) {
                    Section {
                        Text(appName)
                            .bold()
                        Text("Version: \(releaseVersionNumber) (build \(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 5) {
                    Section("Website") {
                        Link(websiteDomain, destination: websiteURL)

                        if let privacyURL {
                            Link("Privacy Policy", destination: privacyURL)
                        }
                        if let termsURL {
                            Link("Terms & Conditions", destination: termsURL)
                        }
                        if let tutorialURL {
                            Link("Tutorial", destination: tutorialURL)
                        }
                    }
                }

                if let copyright {
                    Text(copyright)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center) // NOTE to center the copyright on watch
        }
        .navigationTitle("About")
    }

    private var appName: String {
        Bundle.main.appName ?? ""
    }

    private var releaseVersionNumber: String {
        Bundle.main.releaseVersionNumber ?? ""
    }

    private var buildNumber: String {
        Bundle.main.buildNumber ?? ""
    }

    private var websiteDomain: String {
        websiteURL.host ?? "unknown"
    }
}

struct AboutView_Previews: PreviewProvider {
    static let url = URL(string: "https://gym-routine-tracker.github.io")!

    static var previews: some View {
        NavigationStack {
            AboutView(//                appName: "Gym Routine Tracker Plus",
//                      displayName: "Gym RT+",
//                      releaseVersionNumber: "1.0",
//                      buildNumber: "100",
                websiteURL: url,
                privacyURL: url.appending(path: "privacy"),
                termsURL: url.appending(path: "terms"),
                tutorialURL: url.appending(path: "tutorial"),
                copyright: "Copyright 2022, 2023 OpenAlloc LLC")
            {
                Image(systemName: "g.circle.fill")
                    .imageScale(.large)
            }
        }
    }
}
