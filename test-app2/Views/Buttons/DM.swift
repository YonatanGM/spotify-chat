//
//  DM.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI

struct DM: View {
    @EnvironmentObject var model: AppStateModel
    @State var isTapping: Bool = false
    @State var didCreateGroup = false
    let recipient: Message.ChatUserItem
    
    @State var navigateToChat = false
    
    var group: Group? {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            return nil
        }
        return model.groups.filter({ $0.1.name == "\(recipient.id),\(currentUserID)"
            || $0.1.name == "\(currentUserID),\(recipient.id)" }).first?.1
      
    }
    
    var buttonHeight = 25.0
    
    var body: some View {
        NavigationLink(isActive: $navigateToChat,
                       destination: {
                            if let groupID = group?.id {
                                SwiftyChatView(groupID: groupID)
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
        .isDetailLink(false)
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
            guard let group = group else {
                // create the group
                // and navigate to the chat view
                withAnimation(.easeIn(duration: 0.1)) {
                    isTapping = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isTapping = false
                    }
                    DatabaseManager.shared.directMessage(user: recipient) { didCreateGroup in
                        if didCreateGroup == true {
                            print("created group with user \(recipient.id)")
                            self.didCreateGroup = true
                            navigateToChat = true
                        }
                    }
                }
                return
            }

            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                if group.pending == true {
                    DatabaseManager.shared.acceptPendingInvitation(group.id) { success in
                        navigateToChat = true
                    }
                } else {
                    navigateToChat = true
                }
            }
        }
    }
}

