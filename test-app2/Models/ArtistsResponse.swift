//
//  TopArtistsResponse.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation

public struct ArtistsResponse: Codable, Equatable {
    public static func == (lhs: ArtistsResponse, rhs: ArtistsResponse) -> Bool {
        return Set(lhs.items.map { $0.id }) == Set(rhs.items.map { $0.id })
    }
    
    let items: [Artist]
    
}

public struct Artist: Codable {
    let id: String
    let name: String
    let external_urls: [String: String] // check this, could be optional 
    let genres: [String]?
    let images: [APIImage]?
    let uri: String
}
