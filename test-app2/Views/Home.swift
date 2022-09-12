//
//  Home.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct Home: View {
    var body: some View {
        ZStack {

            LinearGradient(colors: [
                Color(.sRGB,
                      red: Double(20) / 255,
                      green: Double(20) / 255,
                      blue: Double(20) / 255,
                      opacity: 0.75),
                Color(.sRGB,
                      red: Double(25) / 255,
                      green: Double(25) / 255,
                      blue: Double(25) / 255,
                      opacity: 1)

            ], startPoint: .topLeading, endPoint: .center)
            .ignoresSafeArea(.all, edges: .all)

            ScrollView(showsIndicators: false) {
//                GroupsView()
                UsersView()
                    
                TopArtistsView()
                    
                TopTracksView()
            }
            .overlay(Bar().padding(5), alignment: .top)
        }
       
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
