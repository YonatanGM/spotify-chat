//
//  ConversationsView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct ConversationsView: View {
    var body: some View {
        ZStack {

            LinearGradient(colors: [
                Color(.sRGB,
                      red: Double(20) / 255,
                      green: Double(20) / 255,
                      blue: Double(20) / 255,
                      opacity: 0.75),
                Color(.sRGB,
                      red: Double(10) / 255,
                      green: Double(10) / 255,
                      blue: Double(10) / 255,
                      opacity: 1)

            ], startPoint: .topLeading, endPoint: .bottom)
            .ignoresSafeArea(.all, edges: .all)
            
            ScrollView(showsIndicators: false) {
   
                   
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)

            
            // bar
            .overlay(
                HStack {
                    Spacer()
                   
                    NewGroupButton()

                }
                .frame(height: Double(UIScreen.main.bounds.width) / 10)
                .padding(5), alignment: .top
            )
        }
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}
