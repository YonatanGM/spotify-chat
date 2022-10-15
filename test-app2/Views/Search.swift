//
//  SearchBar.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.09.22.
//

import Foundation
import UIKit
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @EnvironmentObject var model: AppStateModel
    
    var searchResultsDisplay: [Message.ChatUserItem] {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else { return [] }
        return model.searchResults.filter { foundUser in
            foundUser.id != currentUserID
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
        VStack(spacing: 10) {
            if !model.searchResults.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(searchResultsDisplay, id: \.id) { user in
                            UserCard(user: user)
                                .padding(.horizontal, 1)
                                .padding(.leading, user.id == searchResultsDisplay.first?.id ? 10 : 0)
                        }
                    }
                  
                }
                .animation(.spring(), value: model.searchResults.count)
                if !termsDisplay.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(termsDisplay.unique, id: \.self) { term in
                                HStack {
                                    Text(term)
                                        .font(.body)
                                }
                                .padding([.horizontal], 10)
                                .padding([.vertical], 7.5)
                                .foregroundColor(.white)
                                .background(
                                    Color.backdrop
                                )
                                .clipShape(Capsule())
                            }
                        }
                        .animation(.spring(), value: termsDisplay)
                    }
                    .clipShape(Capsule())
                    .padding(.horizontal, 10)
                }
            }
            
            HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search", text: $searchText) {
                     termsDisplay = terms
                     DatabaseManager.shared.queryUsersByArtistOrTrackName(terms) { terms, users in
                         if self.terms == terms {
                             model.searchResults = users
                         }
                     }
                 }
                 .accentColor(.white)
                 .keyboardType(.webSearch)
                 .disableAutocorrection(true)
                 .onChange(of: searchText) {
                     if $0.isEmpty {
                         model.searchResults = []
                     }
                 }
             }
             .foregroundColor(.white)
             .padding(.leading, 13)
             .frame(height: 40)
             .background(Color.backdrop)
             .clipShape(Capsule())
             .padding([.horizontal, .bottom], 10)
        }
     }
 }


