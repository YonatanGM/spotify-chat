//
//  Playlist.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.09.22.
//

import Foundation

struct PlaylistsResponse: Codable {
    let items: [Playlist]
}


struct Playlist: Codable {
    // let description: String
    // let external_urls: [String: String]
    let id: String
    // let images: [APIImage]
    let name: String
    // let owner: User
}
