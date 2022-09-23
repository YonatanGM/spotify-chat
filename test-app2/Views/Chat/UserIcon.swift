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
    @State var scale = 0.0
    
    private func scaleAmount(posX: Double) -> Double {
        return abs(UIScreen.main.bounds.size.width / 2 - posX) / (UIScreen.main.bounds.size.width / 2)
    }
    
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
                                .frame(width: 10)
                                .foregroundColor(.green)
                                .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                        y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                    .opacity(isOnline ? 1.0 : 0.0 )
                )
                .scaleEffect(max(0.01, 1 - scale))
                .overlay(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.frame(in: .global).midX) { _ in
                                withAnimation(.easeIn) {
                                    scale = scaleAmount(posX: geometry.frame(in: .global).midX)
                                }
                            }
                            .onAppear {
                                scale = scaleAmount(posX: geometry.frame(in: .global).midX)
                            }
                    }
                    
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
                                .frame(width: 15)
                                .offset(x: cos(Angle(degrees: 45).radians) * geometry.size.width / 2,
                                        y: sin(Angle(degrees: 45).radians) * geometry.size.height / 2)
                                .opacity(0.25)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                )
                .rotationEffect(.degrees(-90))
                .scaleEffect(max(0.01, 1 - scale) + 0.03)
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10)
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


