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
            !addedUsers.contains(foundUser) && !model.blockedUsers.contains { $0 == foundUser.id }
        }
    }
    
    var terms: [String] {
        searchText
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map {
                $0.lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression)
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
                                GeometryReader { geometry in
                                    ZStack {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 10)
                                            .foregroundColor(.white)
                                            .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                    y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                            .shadow(radius: 5)
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                }
                            )
//                            .overlay(
//                                Image(systemName: "x.circle.fill")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 15, height: 15)
//                                , alignment: .topTrailing)
                            .matchedGeometryEffect(id: user.id, in: animation)
                        
                    } else {
                        
                        UserPicInitials(name: user.userName)
                            .frame(height: Double(UIScreen.main.bounds.width) / 12)
                            .overlay(
                                GeometryReader { geometry in
                                    ZStack {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 10)
                                            .foregroundColor(.white)
                                            .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                    y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                            .shadow(radius: 5)
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                }
                            )
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
            .padding([.horizontal], 15)
//            
//            Text("Find")
//                .font(Font.custom("Modulus", size: 30))
//                .padding([.horizontal], 10)
            
            // search bar
            VStack(spacing: 7.5) {
                // search results
                if !searchResultsDisplay.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(searchResultsDisplay, id: \.id) { user in
                                UserCardGroupCreation(user: user, namespace: animation)
                                    .padding(.horizontal, 1)
                                     .padding(.leading, searchResultsDisplay.first?.id == user.id ? 10 : 0)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5)) {
                                            if addedUsers.count < 10 {
                                                addedUsers.append(user)
                                            }
                                        }
                                    }
                            }
                        }

                    }
                }
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
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
                .padding([.horizontal], 15)
            }
            .header(title: "Find", subtitle: "Search by artist or track names (comma separated). You can add up to ten people.")

            Spacer()
        }
    }
}
