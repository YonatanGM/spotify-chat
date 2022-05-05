//
//  TopTrackResponse.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation

struct TopTracksResponse: Codable {
    let items: [Track]
}

struct Track: Codable {
    let id: String
    let name: String
    let artists: [Artist]
    let external_urls: [String: String]
    let preview_url: String?

    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
}


