//
//  DM.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI

struct DM: View {
    @EnvironmentObject var model: AppStateModel
    @State var showChat = false
    @State var isTapping: Bool = false
    @State var didCreateGroup = false
    let recipient: Message.ChatUserItem
    
    var groupID: String? {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            return nil
        }
        return model.groups.filter({ $0.1.name == "\(recipient.id),\(currentUserID)"
            || $0.1.name == "\(currentUserID),\(recipient.id)" }).first?.0
    }
    
    var buttonHeight = 25.0
    
    var body: some View {
        NavigationLink(isActive: $showChat,
                       destination: {
                            if let groupID = groupID {
                                SwiftyChatView(groupID: groupID, showChat: $showChat)
                                    .onDisappear {
                                        // if it's a new group and the user navigates back to this view
                                        // without sending any message
                                        // delete the group
                                        if didCreateGroup {
                                            // check if no message was sent
                                            if let messages = model.groups[groupID]?.messages, messages.isEmpty {
                                                DatabaseManager.shared.deleteGroup(groupID) { _ in }
                                            }
                                            
                                        }
                                    }
                            }
                       },
                       label: { EmptyView() })
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
                .frame(height: buttonHeight)
                .scaleEffect(0.5)
        }
        .padding(buttonHeight / 5)
        .foregroundColor(.white)
        .background(Color.backdrop)
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                if groupID == nil {
                    // create the group
                    // and navigate to the chat view
                    DatabaseManager.shared.directMessage(user: recipient) { didCreateGroup in
                        if didCreateGroup == true {
                            print("created group with user \(recipient.id)")
                            self.didCreateGroup = true
                            showChat = true
                        }
                    }
                } else {
                    showChat = true 
                }
            }
        }
    }
}

