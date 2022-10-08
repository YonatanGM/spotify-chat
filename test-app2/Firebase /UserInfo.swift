//
//  User.swift
//  test-app2
//
//  Created by Yonatan Mamo on 11.09.22.
//

import Foundation
import SwiftUI

struct UserInfo {
    
    let id: String
    let name: String
    let photoURL: String?
    let genreDisplay: String?
    
    var size: CGFloat = .zero
    var offset = CGSize.zero
}
