//
//  ConversationsView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import SwiftUI

struct ConversationsView: View {
    
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {

        NavigationView {
            List(model.conversations) { conversation in
                NavigationLink(destination: {
                    Chat(otherUser: ChatUser(id: conversation.otherUserID, name: conversation.otherUserName), conversationID: conversation.id)
                }) {
                    HStack {
                        Text(conversation.otherUserName)
                            .bold()
                            .foregroundColor(Color(.label))
                            .font(.system(size: 32))

                        Spacer()
                    }
                    .padding()
                
                }
                
            }
        }
        .navigationViewStyle(.stack)
        
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}
