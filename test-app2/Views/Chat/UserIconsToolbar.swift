//
//  UserIconsToolbar.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.09.22.
//

import SwiftUI

struct UserIconsToolbar: View {
    
    @Namespace var middleID
    @Namespace var otherID
    let numOfImages = 5
    @State var drag: CGSize = .zero
    let users: [UserInfo]
    var body: some View {
        
        HStack {
            ScrollViewReader { proxy in
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(users.enumerated()), id: \.offset) { index, user in
                                if index == users.count / 2 {
                                    UserIconAnimated(user: user)
                                        .id(middleID)
                                } else {
                                    UserIconAnimated(user: user)
                                }
                            }
                        }
                        .frame(minWidth: geometry.size.width)
                    }
                    .clipShape(Capsule())
                    .onAppear {
                        proxy.scrollTo(middleID)
                    }
                }
            }
        }
        
    }
}

