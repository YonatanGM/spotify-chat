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
    
    var currentUserID: String? {
        AuthManager.shared.currentUser?.uid
    }
    
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
                            .frame(height: Double(UIScreen.main.bounds.width) / 10)
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
                        
                        
                        Image(systemName: "circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                        
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: Double(UIScreen.main.bounds.width) / 10)
                            .shadow(radius: 5)
                            .overlay(
                                Text(user.userName.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                                    .font(.title)
                                    .fontWeight(.thin)
                                    .foregroundColor(.white)
                  
                                    
                            , alignment: .center)
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
            
            Text("Find")
                .fontWeight(.light)
                .font(.title)
                .padding([.horizontal], 10)
            
            ZStack {
                Rectangle()
                    .foregroundColor(.backdrop)
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText) {
                        let terms = searchText
                            .components(separatedBy: ",")
                            .filter { !$0.isEmpty }
                            .map { $0.lowercased()
                                    .replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression)
                            }
                        
                        model.queryUsersByArtistOrTrackName(terms) { results in
                            searchResults = results
                        }
                        
                    }
                    
                    .accentColor(.white)
                    .keyboardType(.webSearch)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) {
                        if $0.isEmpty {
                            searchResults = []
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.leading, 13)
            }
            .frame(height: 40)
            .clipShape(Capsule())
            .padding([.horizontal], 10)
            // search results
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(searchResults.filter { userFromSearch in
                        !model.suggestedUsers.map { $0.id }.contains(userFromSearch.id)
                    }, id: \.id) { user in
                        UserCardGroupCreation(user: user, namespace: animation)
                            .padding([.horizontal], 1)
                            .padding([.leading], searchResults.first?.id == user.id ? 10 : 0)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5)) {
                                    addedUsers.append(user)
                                }
                            }
                    }
                }

            }
            .padding([.bottom])
            
            
            Text("Suggested users")
                .fontWeight(.light)
                .font(.title)
                .padding([.horizontal], 10)
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    ForEach(model.suggestedUsers.filter { $0.id != currentUserID && !addedUsers.contains($0) }, id: \.id) { user in
                        UserCardGroupCreation(user: user, namespace: animation)
                            .padding([.horizontal], 1)
                            .padding([.leading], model.suggestedUsers.first?.id == user.id ? 10 : 0)
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
