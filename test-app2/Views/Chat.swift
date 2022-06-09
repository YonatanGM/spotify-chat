//
//  ChatVIew.swift
//  test-app2
//
//  Created by Yonatan Mamo on 08.06.22.
//

import SwiftUI
import SwiftyChat


struct Chat: View {
    @EnvironmentObject var model: AppStateModel
    @State private var scrollToBottom = false
    
    // MARK: - InputBarView variables
    @State private var message = ""
    @State private var isEditing = false
    
    var currentChatUser: Message.ChatUserItem? {
        guard let currentUserID = AuthManager.shared.currentUser?.uid,
              let currentUserName = AuthManager.shared.currentUser?.displayName else {
                return nil
        }
        
        return Message.ChatUserItem(userName: currentUserName,
                                    avatarURL:  AuthManager.shared.currentUser?.photoURL,
                                    avatar: nil,
                                    id: currentUserID)
    }
    
    var body: some View {
        
        chatView
    }
        
    
    private var chatView: some View {

        ChatView<Message.ChatMessageItem, Message.ChatUserItem>(
            messages: Binding(
                get: {
                    model.messages
                },
                set: {
                    model.messages = $0
            }),
            scrollToBottom: $scrollToBottom
        
        ) {

            BasicInputView(
                message: $message,
                isEditing: $isEditing,
                placeholder: "Type something",
                onCommit: { messageKind in
                    if let currentChatUser = currentChatUser {
                        model.messages.append(
                            .init(user: currentChatUser,
                                  messageKind: messageKind,
                                  isSender: true)
                        )
                    }

                    scrollToBottom = true
                }
            )
            .padding(8)
            .padding(.bottom, isEditing ? 0 : 8)
            .accentColor(.chatBlue)
            .background(Color.primary.colorInvert())
            .animation(.linear)
            .embedInAnyView()
            
        }
        // ▼ Optional, Present context menu when cell long pressed
        .messageCellContextMenu { message -> AnyView in
            switch message.messageKind {
            case .text(let text):
                return Button(action: {
                    print("Copy Context Menu tapped!!")
                    UIPasteboard.general.string = text
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc")
                }.embedInAnyView()
            default:
                // If you don't want to implement contextMenu action
                // for a specific case, simply return EmptyView like below;
                return EmptyView().embedInAnyView()
            }
        }
        // ▼ Required
        .environmentObject(ChatMessageCellStyle.basicStyle)
        .navigationBarTitle("Basic")
        .listStyle(PlainListStyle())
    }
}



extension Color {
    static let chatBlue = Color(#colorLiteral(red: 0.1405690908, green: 0.1412397623, blue: 0.25395751, alpha: 1))
    static let chatGray = Color(#colorLiteral(red: 0.7861273885, green: 0.7897668481, blue: 0.7986581922, alpha: 1))
}

let futuraFont = Font.custom("Futura", size: 17)

internal extension ChatMessageCellStyle {
    
    static let basicStyle = ChatMessageCellStyle(
        incomingTextStyle: .init(
            textStyle: .init(textColor: .black, font: futuraFont),
            textPadding: 16,
            attributedTextStyle: .init(textColor: .black),
            cellBackgroundColor: Color.chatGray,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.topRight, .bottomRight, .bottomLeft]
        ),
        outgoingTextStyle: .init(
            textStyle: .init(textColor: .white, font: futuraFont),
            textPadding: 16,
            cellBackgroundColor: Color.chatBlue,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.topLeft, .bottomRight, .bottomLeft]
        ),
        incomingAvatarStyle: .init(imageStyle: .init(imageSize: .zero))
    )
    
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat()
    }
}
