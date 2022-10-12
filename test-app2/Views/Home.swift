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
    
    @State var canRefresh = true

    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                UsersView()
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                TopArtistsView(artists: suggestedArtists)
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                TopTracksView(tracks: suggestedTracks)
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))

                SearchBar(searchText: $searchText)
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                    .id(bottomID)
            }
            .listStyle(.plain)
            .refreshable {
                // can only refresh every 5 minutes, might decrease this later
                guard canRefresh else { return }
                let didRefresh = await DatabaseManager.shared.refreshUser()
                if didRefresh {
                    canRefresh = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
                       canRefresh = true
                    }
                }
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
        .navigationTitle("⁢⁢\u{17B5} \u{17B4} \u{115F}")
        .navigationBarItems(trailing: CurrentUserSettings())
  
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
        
    }
}

