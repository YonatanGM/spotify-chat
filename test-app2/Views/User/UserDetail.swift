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
                if let topArtists = user.topArtists {
                    UserBackground(urls: topArtists.items.compactMap { $0.images?.first?.url })
                        .edgesIgnoringSafeArea(.horizontal)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 0.5)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                }
                HStack {
                    Spacer()
                    UserIcon(user: .init(id: user.id, name: user.userName, photoURL: user.avatarURL?.absoluteString, genreDisplay: nil))
                        .frame(width: profilePicHeight)
                    
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
                
                if let bio = user.bio {
                    UserBio(bioText: bio)
                         .padding(.vertical)
                }
                
                if let artists = user.topArtists?.items {
                    TopArtistsView(artists: artists)
                        .header(title: "Fan of")
                        .offset(x: 12)
                        .padding(.top, user.bio == nil ? 45 : 0)
                }
                if let tracks = user.topTracks?.items {
                    TopTracksView(tracks: filterAvailableTracks(tracks: tracks))
                        .header(title: "Favorite tracks")
                        .offset(x: 12)
                        .padding(.bottom)
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
        }
    }
    
    private func filterAvailableTracks(tracks: [Track]) -> [Track]{
        return tracks
                .filter {
                    guard let currentUser = model.currentUser else { return true }
                    if let availableMarkets = $0.available_markets,
                       let country = currentUser.country {
                        if availableMarkets.contains(country) {
                            return $0.explicit ? currentUser.filterEnabled == false : true
                        } else {
                            return false
                        }
                    } else {
                        return $0.explicit  ? currentUser.filterEnabled == false : true
                    }
                }
    }
}


