//
//  UserDetail.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.10.22.
//

import SwiftUI
import SDWebImageSwiftUI


struct UserDetail: View {
    @EnvironmentObject var model: AppStateModel
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
    
    let profilePicHeight = Double(UIScreen.main.bounds.width) / 3.5
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
                        }
                    }
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            if let isFollowing = model.followedUsers[user.id] {
                                FollowOnSpotify(isFollowing: isFollowing) {
                                    if isFollowing {
                                        APICaller.shared.unfollowUser(with: user.id) { successfullyUnfollowed in
                                            if successfullyUnfollowed {
                                                DispatchQueue.main.async {
                                                    model.followedUsers[user.id] = false
                                                }
                                            }
                                        }
                                    } else {
                                        APICaller.shared.followUser(with: user.id) { successfullyFollowed in
                                            if successfullyFollowed {
                                                DispatchQueue.main.async {
                                                    model.followedUsers[user.id] = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            DM(recipient: user)
                                .offset(x: 5)
                            Spacer()
                        }
                        .padding(.bottom, 1)
                        
                        if let topGenres = user.topGenres {
                            GeometryReader { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 1) {
                                        ForEach(topGenres, id: \.self ) { genre in
                                            GenresAnimatedIcon(genre: genre, parentFrame: geometry.size)
                                        }
                                    }
                                }
                                .clipShape(Capsule())
                                .coordinateSpace(name: "userDetailGenres")
                                .padding(.horizontal, 10)
                            }
                            .frame(height: 20)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal)
                .offset(y: -1 * profilePicHeight / 2)
                .padding(.bottom, -1 * profilePicHeight / 3)
                
                if let artists = user.topArtists?.items {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Likes")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .padding(.leading)
                        TopArtistsView(artists: artists)
                    }
                    
                  
                }
                if let tracks = user.topTracks?.items {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Favorite tracks")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .padding(.leading)
                        TopTracksView(tracks: tracks)
                    }
                  
                }
              
                
                
            }
            
        }
     
//        .navigationBarTitle("user.userName\")
         
        .navigationTitle(user.userName)
        
        .onAppear {
            // check if current user follows this user
            if model.followedUsers[user.id] == nil {
                // api call
                APICaller.shared.checkIfCurrentUserFollowsUsers(with: [user.id]) { result in
                    switch result {
                    case .success(let dict):
                        DispatchQueue.main.async {
                            model.followedUsers[user.id] = dict[user.id]
                        }
                    case .failure(let error):
                        print("couldn't check if current user follows user \(user.id): \(error.localizedDescription)")
                    }
                }
            }
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


