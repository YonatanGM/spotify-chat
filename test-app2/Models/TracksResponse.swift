//
//  TopTrackResponse.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation

public struct TracksResponse: Codable {
    let items: [Track]
}

public struct Track: Codable {
    var album: Album?
    let id: String
    let name: String
    let artists: [Artist]
    let external_urls: [String: String]
    let preview_url: String?

    // let disc_number: Int
    // let duration_ms: Int
    let explicit: Bool
    // 5let uri: String
    let available_markets: [String]?
}



public struct Album: Codable {
    // let album_type: String
    // let available_markets: [String]? // check this
    let id: String
    var images: [APIImage]
    let name: String
    // let release_date: String
    // let total_tracks: Int
    // let artists: [Artist]
}


