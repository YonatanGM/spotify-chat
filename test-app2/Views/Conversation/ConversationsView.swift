//
//  ConversationsView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct ConversationsView: View {
    @EnvironmentObject var model: AppStateModel
    var body: some View {
        ZStack(alignment: .top) {

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
                // list groups the user is currently in first
                VStack {
                    ForEach(model.groups, id: \.id) { group in
                        ConversationGroupRow(group: group)
                    }
                    // the pending ones
                    ForEach(model.pendingGroups, id: \.id) { group in
                        ConversationGroupRowPending(group: group)
               
//                        HStack {
//                            Text("\(group)")
//                            Spacer()
//                        }
//                        .border(.red)
                       
                    }
                    
                }

                   
            }
            .padding([.horizontal], 10)
          
 
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            
            // bar
            .navigationBarItems(trailing: NewGroupButton()
                .frame(height: 20)
            
            )
            /*
            .overlay(
                HStack {
                    Spacer()
                   
                    NewGroupButton()

                }
                .frame(height: Double(UIScreen.main.bounds.width) / 10)
                .padding(10), alignment: .top
            )
             */
            
            
            
        }
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}
