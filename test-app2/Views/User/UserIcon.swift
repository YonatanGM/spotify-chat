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
    var onlineIndicatorHeight: CGFloat?
    let showOnlineIndicator: Bool 
    
    init(user: UserInfo, showOnlineIndicator: Bool = true, onlineIndicatorHeight: CGFloat? = nil) {
        self.user = user
        self.onlineIndicatorHeight = onlineIndicatorHeight
        self.showOnlineIndicator = showOnlineIndicator
    }
    
    var body: some View {
        if let urlString = user.photoURL,
           let url = URL(string: urlString) {
            AnimatedImage(url: url)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .shadow(radius: 5)
                .mask {
                    Circle()
                        .overlay {
                            if isOnline {
                                GeometryReader { geometry in
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                        
                                            .frame(width: onlineIndicatorHeight.map { $0 * 2} ?? geometry.size.width / 12 * 2)
                                            .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                    y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                            .compositingGroup()
                                            .luminanceToAlpha()
                                        
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .compositingGroup()
                        .luminanceToAlpha()
                }
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: onlineIndicatorHeight ?? geometry.size.width / 12)
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
                .mask {
                    Circle()
                        .overlay {
                            if isOnline {
                                GeometryReader { geometry in
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: onlineIndicatorHeight.map { $0 * 2} ?? geometry.size.width / 12 * 2)
                                            .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                    y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                            .compositingGroup()
                                            .luminanceToAlpha()
                                        
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .compositingGroup()
                        .luminanceToAlpha()
                }
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: onlineIndicatorHeight ?? geometry.size.width / 12)
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


