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
    var body: some View {
        VStack(spacing: 0) {
            // search results
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(model.searchResults, id: \.id) { user in
                        UserCard(user: user)
                            .padding([.horizontal], 1)
                            .animation(nil)
                    }
                }
                .animation(.spring())

            }
            
            
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
                             model.searchResults = results

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
             //.cornerRadius(20)
             .padding()
            
        }

     }
 }
