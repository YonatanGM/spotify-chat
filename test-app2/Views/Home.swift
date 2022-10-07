//
//  Home.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct Home: View {
    @EnvironmentObject var model: AppStateModel
    @State private var searchText = ""
    @Namespace var bottomID
    var suggestedArtists: [Artist] {
        model.suggestedUsers.compactMap { $0.topArtists?.items.first }
    }
    var suggestedTracks: [Track] {
        model.suggestedUsers.compactMap { $0.topTracks?.items.first }
    }
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                UsersView()
                TopArtistsView(artists: suggestedArtists)
                TopTracksView(tracks: suggestedTracks)
                Spacer()
                SearchBar(searchText: $searchText)
                    .id(bottomID)
            }
            .overlay(Bar().padding(5), alignment: .top)
            .onChange(of: model.scrollToBottom) { value in
                if value == true {
                    withAnimation {
                        proxy.scrollTo(bottomID)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            model.scrollToBottom = false
                        }
                    }
                }
            }
            .onChange(of: model.searchResults) { _ in
                proxy.scrollTo(bottomID)
                
            }
        }
        .background(
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
            .ignoresSafeArea(.all, edges: .all)
        )
        .navigationBarItems(trailing: CurrentUserSettings())
        
    }
}

