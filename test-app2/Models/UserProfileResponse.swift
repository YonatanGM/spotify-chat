//
//  UserProfile.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation



struct UserProfileResponse: Codable, Identifiable {
    let country: String // is this always available, seems like
    let display_name: String
    let email: String?  // shouldn't be optional
    let explicit_content: [String: Bool] // what is this?
    // let external_urls: [String: String]
    // let followers: [String: Codable?]
    let id: String
    let images: [APIImage]
    let product: String // what is this?
}


public struct APIImage: Codable {
    let url: String
}


//{
//    country = DE;
//    "display_name" = Yonatan;
//    "explicit_content" =     {
//        "filter_enabled" = 0;
//        "filter_locked" = 0;
//    };
//    "external_urls" =     {
//        spotify = "https://open.spotify.com/user/gxs474imdlfuevystwm5jwb8r";
//    };
//    followers =     {
//        href = "<null>";
//        total = 0;
//    };
//    href = "https://api.spotify.com/v1/users/gxs474imdlfuevystwm5jwb8r";
//    id = gxs474imdlfuevystwm5jwb8r;
//    images =     (
//    );
//    product = open;
//}
//
