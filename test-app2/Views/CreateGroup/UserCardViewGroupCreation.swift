//
//  UserCardViewGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI


struct UserCardViewGroupCreation: View {
    @EnvironmentObject var model: AppStateModel
    @State var selectedUserID: String? = nil
    @State var isTapping = false
    @Binding var addedUsers: [Message.ChatUserItem]
    @State var searchText = ""
    @State var searchResults = [Message.ChatUserItem]()
    @Namespace private var animation

    var suggestedUsersDisplay: [Message.ChatUserItem] {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else { return [] }
        return model.suggestedUsers.filter { $0.id != currentUserID && !addedUsers.contains($0) }
    }
    
    var searchResultsDisplay: [Message.ChatUserItem] {
        // guard let currentUserID = AuthManager.shared.currentUser?.uid else { return [] }
        return searchResults.filter { foundUser in
            !addedUsers.contains(foundUser) // && !model.suggestedUsers.map { $0.id  }.contains(userFromSearch.id)
        }
    }
    
    var terms: [String] {
        searchText
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map {
                $0.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression)
            }
    }
    
    @State var termsDisplay = [String]()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Spacer()
                ForEach(addedUsers, id: \.id) { user in
                    if let url = user.avatarURL {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: Double(UIScreen.main.bounds.width) / 12)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5))  {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                            }
                            .overlay(
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                , alignment: .topTrailing)
                            .matchedGeometryEffect(id: user.id, in: animation)
                        
                    } else {
                        
                        UserPicInitials(name: user.userName)
                            .frame(height: Double(UIScreen.main.bounds.width) / 12)
                            .overlay(
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                , alignment: .topTrailing)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5))  {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                            }
                            .matchedGeometryEffect(id: "picInitial" + user.id, in: animation)
                    }
                }
                Spacer()
            }
            .frame(height: 50)
            .padding([.horizontal], 10)
            
            Text("Find")
                .fontWeight(.light)
                .font(.title)
                .padding([.horizontal], 10)
            
            // search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText) {
                    // guard termsDisplay != terms else { return }
                    termsDisplay = terms
                    DatabaseManager.shared.queryUsersByArtistOrTrackName(terms) { terms, users in
                        if self.terms == terms {
                            searchResults = users
                        }
                    }
                }
                .accentColor(.white)
                .keyboardType(.webSearch)
                .disableAutocorrection(true)
                .onChange(of: searchText) {
                    if $0.isEmpty {
                        searchResults = []
                        termsDisplay = []
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.leading, 13)
            .frame(height: 40)
            .background(Color.backdrop)
            .clipShape(Capsule())
            .padding([.horizontal], 10)
            
            // search terms
            if !termsDisplay.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(termsDisplay.unique, id: \.self) { term in
                            Button(term){}
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .foregroundColor(.white)
                                .allowsHitTesting(false)
                        }
                        
                    }
                    .animation(.spring(), value: termsDisplay)
                }
                .clipShape(Capsule())
                .padding(.leading, 10)
                .padding(.vertical, 5)
            }
            
            // search results
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(searchResultsDisplay, id: \.id) { user in
                        UserCardGroupCreation(user: user, namespace: animation)
                            .padding(.horizontal, 1)
                             .padding(.leading, searchResultsDisplay.first?.id == user.id ? 10 : 0)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5)) {
                                    addedUsers.append(user)
                                }
                            }
                    }
                }

            }
            Spacer()
        }
    }
}
