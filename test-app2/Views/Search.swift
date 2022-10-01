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
        VStack(spacing: 0) {
            if !model.searchResults.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(model.searchResults, id: \.id) { user in
                            UserCard(user: user)
                                .padding([.horizontal], 1)
                        }
                    }
                  
                }
                .animation(.spring(), value: model.searchResults.count)
                .padding(5)
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
                        .animation(.spring())
                    }
                    .padding(5)
                }
            }
            
            ZStack {
                    Rectangle()
                       .foregroundColor(.backdrop)
                 HStack {
                     Image(systemName: "magnifyingglass")
                     TextField("Search", text: $searchText) {
                         model.queryUsersByArtistOrTrackName(terms) { results in
                             model.searchResults = results
                             termsDisplay = terms
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
             }
             .frame(height: 40)
             .clipShape(Capsule())
             .padding(5)
        }
     }
 }


