//
//  Home.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct Home: View {
    @State private var searchText = ""
    @Namespace var bottomID
    @EnvironmentObject var model: AppStateModel
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
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
    //                GroupsView()
                    UsersView()
                        
                    TopArtistsView()
                        
                    TopTracksView()
                    
                    SearchBar(searchText: $searchText)
                        .id(bottomID)
                        .padding([.bottom])
                       
                }
                
                .overlay(Bar().padding(5), alignment: .top)
                .onChange(of: model.scrollToBottom) { value in
                    if value == true {
                        withAnimation(Animation.easeInOut(duration: 1)) {
                            proxy.scrollTo(bottomID)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                model.scrollToBottom = false
                            }
                        }
                    }
                    
                }
            }
        }
       
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
