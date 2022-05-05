//
//  AuthResponse.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.04.22.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
