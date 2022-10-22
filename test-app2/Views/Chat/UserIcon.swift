//
//  UserIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserIcon: View {
    let user: UserInfo
    @State var onlineStatusHandle: UInt?
    @State var isOnline = false
    
    var body: some View {
        if let urlString = user.photoURL,
           let url = URL(string: urlString){
            AnimatedImage(url: url)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .shadow(radius: 5)
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 7.5)
                                .foregroundColor(.green)
                                .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                        y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                    .opacity(isOnline ? 1.0 : 0.0 )
                )
                .onAppear {
                    // check online status
                    onlineStatusHandle = DatabaseManager.shared.checkOnlineStatus(for: user.id) { status in
                        isOnline = status
                        
                    }
                }
                .onDisappear {
                    if let onlineStatusHandle = onlineStatusHandle {
                        DatabaseManager.shared.removeObserver(with: onlineStatusHandle)
                    }
                }
        } else {
            UserPicInitials(name: user.name)
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 7.5)
                                .foregroundColor(.green)
                                .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                        y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                    .opacity(isOnline ? 1.0 : 0.0 )
                )
                .onAppear {
                    // check online status
                    onlineStatusHandle = DatabaseManager.shared.checkOnlineStatus(for: user.id) { status in
                        isOnline = status
                    }
                }
                .onDisappear {
                    if let onlineStatusHandle = onlineStatusHandle {
                        DatabaseManager.shared.removeObserver(with: onlineStatusHandle)
                    }
                }
        }
    }
}


