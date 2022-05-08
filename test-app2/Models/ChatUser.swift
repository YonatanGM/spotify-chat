//
//  ChatUser.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation

struct ChatUser: Identifiable {
    let id: String
    let name: String
    var email: String?
    var profile_picture: String? 
}
    
    

//    "id": profile.id,
//     "name" : profile.display_name,
//     "email": profile.email,
//     "country": profile.country,
//     "profile_picture": profile.images.first?.url}
