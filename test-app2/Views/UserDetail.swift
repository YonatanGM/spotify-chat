//
//  UserDetail.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.10.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserDetail: View {
    let user: Message.ChatUserItem
    @State var onlineStatusHandle: UInt?
    @State var isOnline = false
    
    var gradient: LinearGradient {
        LinearGradient(colors: [
            Color(.sRGB,
                  red: Double(20) / 255,
                  green: Double(20) / 255,
                  blue: Double(20) / 255,
                  opacity: 0.6),
            Color(.sRGB,
                  red: Double(10) / 255,
                  green: Double(10) / 255,
                  blue: Double(10) / 255,
                  opacity: 1)
            
        ], startPoint: .topLeading, endPoint: .center)

    }
    
    let profilePicHeight = Double(UIScreen.main.bounds.width) / 3
    var artistImageUrls: [URL] {
        guard let urls = (user.topArtists?.items
                                .compactMap { $0.images?.first?.url }
                                .compactMap { URL(string: $0) }) else {
            return []
        }
        return urls
    }
    
    var body: some View {
        ZStack {
            gradient.ignoresSafeArea(.all, edges: .all)
            ScrollView(.vertical, showsIndicators: false) {
                ArtistBackgroundSlideshow(urls: artistImageUrls)
                    .blur(radius: 40, opaque: false)
                    .overlay(
                        ZStack {
                            ArtistBackgroundSlideshow(urls: artistImageUrls)
                                .mask(LinearGradient(
                                   gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .white, location: 0.5)
                                   // .init(color: .clear, location: 1)
                                   ]),
                                   startPoint: .bottom,
                                   endPoint: .top
                               ))

                            
                            // .offset(y: profilePicHeight / 1.25)
                            // .border(.red)
                          
                        }
                    )
                HStack {
                    Spacer()
                    VStack {
                        if let url = user.avatarURL {
                            AnimatedImage(url: url)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: profilePicHeight)
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
                                // .border(.blue)
                        } else {
                            UserPicInitials(name: user.userName)
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
                        }
                    }
                    VStack {
                        FollowOnSpotify()
                            // .border(.blue)
                        if let topGenres = user.topGenres {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 1) {
                                    ForEach(topGenres, id: \.self ) { genre in
                                        GenresAnimatedIcon(genre: genre)
                                            
                                    }
                                }
                            }
                            .clipShape(Capsule())
                   
                        
                            .frame(height: 15)
                            .padding(.horizontal)
                            
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .offset(y: -1 * profilePicHeight / 2)

                Spacer()
            }
            
        }
        .navigationTitle(user.userName)
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

