//
//  currentUserDetail.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CurrentUserDetail: View {
    @EnvironmentObject var model: AppStateModel
    
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
        guard let user = model.currentUser else {
            return []
        }
        guard let urls = (user.topArtists?.items
                                .compactMap { $0.images?.first?.url }
                                .compactMap { URL(string: $0) }) else {
            return []
        }
        return urls
    }
    
    
    var body: some View {
        ZStack {
            if let user = model.currentUser {
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
                        UserIcon(user: .init(id: user.id, name: user.userName, photoURL: user.avatarURL?.absoluteString, genreDisplay: nil), contentMode: .fit)
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                SignOut()
                                DeleteAccount()
                                Spacer()
                            }
                                                      
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
       
                    // bio
                    UserBio(bioText: !model.bioCompletions.isEmpty ? "\" \(model.fullBio.trimmingCharacters(in: .whitespacesAndNewlines)) \"" : model.currentUser?.bio)
                        .overlay(alignment: .leading) {
                            if model.didUnlockPremium {
                                SparklesIconBio()
                                    .offset(x: -20, y: 0)
                            } else {
                                SparklesIconPulsing(size: CGSize(width: 15, height: 15)) {
                                    Task {
                                        do {
                                            try await model.purchase()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    
                    if let artists = user.topArtists?.items {
                        TopArtistsView(artists: artists)
                            .header(title: "Fan of")
                            .offset(x: 12)
                            // .padding(.horizontal)
                    }
                    if let tracks = user.topTracks?.items {
                        TopTracksView(tracks: tracks)
                            .header(title: "Favorite tracks")
                            .offset(x: 12)
                            // .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                  
                }
                .navigationTitle("You")
            }
        }
    }
}

