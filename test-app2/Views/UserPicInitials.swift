//
//  UserPicInitials.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.09.22.
//

import SwiftUI

struct UserPicInitials: View {
    let name: String
    var body: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.gray)
            .scaledToFit()
            .clipShape(Circle())
            .shadow(radius: 5)
            .overlay(
                Text(name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                    .font(.largeTitle)
                    .fontWeight(.thin)
                    .foregroundColor(.white)
                    
            , alignment: .center)
    }
}
