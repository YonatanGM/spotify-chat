//
//  TopArtistsResponse.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation

struct TopArtistsResponse: Codable {
    let items: [Artist]
}

struct Artist: Codable {
    let id: String
    let name: String
    let external_urls: [String: String]
    let genres: [String]?
    let images: [APIImage]?
}
