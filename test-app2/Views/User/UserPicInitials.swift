//
//  UserPicInitials.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.09.22.
//

import SwiftUI

struct UserPicInitials: View {
    let name: String
    let applyShadow: Bool
    
    init(name: String, applyShadow: Bool = true) {
        self.name = name
        self.applyShadow = applyShadow
    }
    
    var body: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.gray)
            .scaledToFit()
            .clipShape(Circle())
            .shadow(radius: applyShadow ? 5 : 0)
            .overlay(
                Text(name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                    .font(.largeTitle)
                    .fontWeight(.thin)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .padding(5)
            , alignment: .center)
    }
}
