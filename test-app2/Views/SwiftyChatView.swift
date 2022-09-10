//
//  ChatVIew.swift
//  test-app2
//
//  Created by Yonatan Mamo on 08.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftyChat


struct SwiftyChatView: View {
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
                                    avatar: UIImage(systemName: "person"),
                                    id: currentUserID)
    }
    
    var body: some View {
        
        chatView
    
    }
        
    
    private var chatView: some View {

        ChatView<Message.ChatMessageItem, Message.ChatUserItem>(
            messages: Binding(get: { model.messages }, set: { _ in }),
            scrollToBottom: $scrollToBottom,
            shouldShowGroupChatHeaders: true
        
        ) {

            InputView(
                message: $message,
                isEditing: $isEditing,
                placeholder: "Type something",
                onCommit: { messageKind in
                    if let currentChatUser = currentChatUser {
                        DatabaseManager.shared.sendMessage(message: .init(user: currentChatUser,
                                                                          messageKind: messageKind,
                                                                          isSender: true))
                    }
                    scrollToBottom = true
                }
            )
//
//            .padding(8)
//            .padding(.bottom, isEditing ? 0 : 8)
//            .accentColor(.chatBlue)
//            .background(Color.primary.colorInvert())
            // .animation(.linear)
             .border(.red)
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
        .listStyle(PlainListStyle())
        // .background(Color.primary.colorInvert())

    }
}





public struct InputView: View {
    
    @Binding private var message: String
    @Binding private var isEditing: Bool
    private let placeholder: String

    @State private var contentSizeThatFits: CGSize = .zero

    private var internalAttributedMessage: Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                NSAttributedString(
                    string: self.message,
                    attributes: [
                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                        NSAttributedString.Key.foregroundColor: UIColor.label,
                    ]
                )
            },
            set: { self.message = $0.string }
        )
    }

    private var onCommit: ((ChatMessageKind) -> Void)?
    
    public init(
        message: Binding<String>,
        isEditing: Binding<Bool>,
        placeholder: String = "",
        onCommit: @escaping (ChatMessageKind) -> Void
    ) {
        self._message = message
        self.placeholder = placeholder
        self._isEditing = isEditing
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onCommit = onCommit
    }

    private var messageEditorHeight: CGFloat {
        min(
            self.contentSizeThatFits.height,
            0.2 * UIScreen.main.bounds.height
        )
    }

    private var messageEditorView: some View {
        MultilineTextField(
            attributedText: self.internalAttributedMessage,
            placeholder: placeholder,
            isEditing: self.$isEditing
        )
        .onPreferenceChange(ContentSizeThatFitsKey.self) {
            self.contentSizeThatFits = $0
        }
        .frame(height: self.messageEditorHeight)
    }

    private var sendButton: some View {
        Button(action: {
            self.onCommit?(.text(message))
            self.message.removeAll()
        }, label: {
 
            Image(systemName: "paperplane.fill")
                .rotationEffect(.degrees(45))
          
        })
        .disabled(message.isEmpty)
    }

    public var body: some View {
        VStack {
            Divider()
            HStack {
                self.messageEditorView
                self.sendButton
            }
        }
    }
    
}


extension Color {
    static let chatBlue = Color(#colorLiteral(red: 0.1405690908, green: 0.1412397623, blue: 0.25395751, alpha: 1))
    static let chatSpotifyColor = Color(#colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 0.5145384934))
    static let chatGray = Color(#colorLiteral(red: 0.7861273885, green: 0.7897668481, blue: 0.7986581922, alpha: 1))
}

let futuraFont = Font.custom("Futura", size: 17)

internal extension ChatMessageCellStyle {

    static let basicStyle = ChatMessageCellStyle(
        incomingTextStyle: .init(
            textStyle: .init(textColor: .white, font: .footnote),
            textPadding: 12,
            attributedTextStyle: .init(textColor: .black),
            cellBackgroundColor: Color.chatSpotifyColor,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
        ),
        outgoingTextStyle: .init(
            textStyle: .init(textColor: .white, font: futuraFont),
            textPadding: 12,
            cellBackgroundColor: Color.chatSpotifyColor,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
            
        ),
        incomingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 0,
                                                     shadowColor: Color.clear)),
        outgoingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 0,
                                                     shadowColor: Color.clear))
    )
    
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        SwiftyChatView()
    }
}
