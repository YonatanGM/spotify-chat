//
//  UserCardGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI


struct UserCardGroupCreation: View {
    let user: Message.ChatUserItem
    let namespace: Namespace.ID
    @State var onlineStatusHandle: UInt?
    @State var isOnline = false

    
    var body: some View {
        VStack {
            
            VStack {
                if let url = user.avatarURL {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: Double(UIScreen.main.bounds.width) / 3)
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
                        .matchedGeometryEffect(id: user.id, in: namespace)
                } else {
                    UserPicInitials(name: user.userName)
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
                        .matchedGeometryEffect(id: "picInitial" + user.id, in: namespace)
                }
                
                HStack {
                    Spacer()
                    Text(user.userName)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 1) {
                        if let topArtistResponse = user.topArtists {
                            ForEach(topArtistResponse.items.prefix(20), id: \.id) { artist in
                                if let urlString = artist.images?.first?.url,
                                   let url = URL(string: urlString) {
                                    ArtistAnimatedIcon(url: url)
                                    
                                    
                                }
                            }
                        }
                    }
                    
                }
                .frame(height: 20)
                .frame(width: 125)
                .cornerRadius(10)
                .animation(nil)
            }
            .padding([.vertical], 10)
            .padding([.horizontal])
            
        }
        .background(Color.backdrop.animation(nil))
        .cornerRadius(5)
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

