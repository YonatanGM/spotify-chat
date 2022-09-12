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
    
    var body: some View {
        ZStack {
             Rectangle()
                .foregroundColor(.backdrop)
             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search ..", text: $searchText)
                     .accentColor(.white)
             }
             .foregroundColor(.white)
             .padding(.leading, 13)
         }
         .frame(height: 40)
         .cornerRadius(13)
         .padding()
     }
 }
