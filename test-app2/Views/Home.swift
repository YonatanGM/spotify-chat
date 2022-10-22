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
                    .header(title: "You matched with")
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                    // .border(.red)
                    .padding(.top, 100)
                  
                TopArtistsView(artists: suggestedArtists)
                    .header(title: "Suggested Aritsts", subtitle: "People like you are fans of")
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                    // .border(.red)
                TopTracksView(tracks: suggestedTracks)
                    .header(title: "Suggested Tracks", subtitle: "Based on top tracks of users like")
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                    // .border(.red)

                SearchBar(searchText: $searchText)
                    .header(title: "Find", subtitle: "Find people that share your music taste")
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(.zero))
                    .padding(.bottom, 5)
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
          
                proxy.scrollTo(bottomID, anchor: .bottom)
                
            }
          
        }
        .iOS { $0.dismissKeyboardOnTappingOutside() }
        .onAppear {
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                print("Family: \(family) Font names: \(names)")
            }
        }
       // .animation(.spring(), value: model.searchResults.count)
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

struct CustomSection: ViewModifier {
    let title: String
    let subtitle: String?
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                // .font(.largeTitle)
                .font(Font.custom("Modulus-Bold", size: 35))
                // .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 10)
            }
            content
                .padding(.vertical)
        }
        
    }
}

extension View {
    func header(title: String, subtitle: String? = nil) -> some View {
        modifier(CustomSection(title: title, subtitle: subtitle))
    }
    
    dynamic func dismissKeyboardOnTappingOutside() -> some View {
        return ModifiedContent(content: self, modifier: DismissKeyboardOnTappingOutside())
    }
}



struct DismissKeyboardOnTappingOutside: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    let keyWindow = UIApplication.shared.connectedScenes
                          .filter({$0.activationState == .foregroundActive})
                          .map({$0 as? UIWindowScene})
                          .compactMap({$0})
                          .first?.windows
                          .filter({$0.isKeyWindow}).first
                    keyWindow?.endEditing(true)
                }
            )
    }
}
