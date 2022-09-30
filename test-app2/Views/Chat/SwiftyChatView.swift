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
    let groupID: String
    @State private var scrollToBottom = false
    
    // MARK: - InputBarView variables
    @State private var message = ""
    @State private var isEditing = false
    
    @State private var showingPopover = false
    @Binding var showChat: Bool
    
    
    
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
            .foregroundColor(.white)
            .background(
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
                        
                    ], startPoint: .topLeading, endPoint: .center)
                    
                    LinearGradient(colors: [
                        Color.clear,
                        Color.backdrop
                        
                    ], startPoint: .center, endPoint: .bottom)
         
                }
                .ignoresSafeArea()
            )

      
  

            .navigationTitle("")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UserIconsToolbar(users: model.groups[groupID]?.users ?? [])
                    
                    
                    
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationBarItems(trailing:
                Menu {
                 
                if let currentChatUser = currentChatUser {
                    if currentChatUser.id == model.groups[groupID]?.admin {
                        Button(action: { }) {
                            Label("Add user", systemImage: "plus")
                        }
                        if #available(iOS 15.0, *) {
                            Button(role: .destructive, action: {
                                DatabaseManager.shared.deleteGroup(groupID) { success in
                                    if success {
                                        showChat = false
                                    }
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } else {
                            // Fallback on earlier versions
                            Button(action: {
                                DatabaseManager.shared.deleteGroup(groupID) { success in
                                    if success {
                                        showChat = false
                                    }
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                    } else {
                        if #available(iOS 15.0, *) {
                            Button(role: .destructive, action: {
                                DatabaseManager.shared.leaveGroup(groupID) { success in
                                    if success {
                                        showChat = false
                                    }
                                }
                            }) {
                                Label("Leave", systemImage: "trash")
                                    .labelStyle(.titleOnly)
                            }
                        } else {
                            // Fallback on earlier versions
                            Button(action: {
                                DatabaseManager.shared.leaveGroup(groupID) { success in
                                    if success {
                                        showChat = false
                                    }
                                }
                            }) {
                                Label("Leave", systemImage: "trash")
                                    .labelStyle(.titleOnly)
                            }
                        }
                    }
                        
                }
                        
                        
                    
                    
                } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(Angle(degrees: 90))
                            .foregroundColor(.white)
                            .contentShape(Rectangle())
                        
                }
               
            )
        
    }
    
    
    private var chatView: some View {
        
        ChatView<Message.ChatMessageItem, Message.ChatUserItem>(
            messages: Binding(get: { model.groups[groupID]?.messages ?? [] },
                              set: { _ in }),
            onMessageCellAppeared: { message in
                // hope this works fine 
                if let index = (model.groups[groupID]?.messages.firstIndex { $0.id == message.id }),
                    let endIndex = model.groups[groupID]?.messages.endIndex {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) / Double(endIndex)) {
                        if let lastSeenMessageID = model.groups[groupID]?.lastSeenMessageID,
                           message.id > lastSeenMessageID {
                            DatabaseManager.shared.setLastSeen(for: groupID, messageID: message.id)
                            // model.groups[groupID]?.lastSeenMessageID = message.id
                        }
                    }
                }


            },
            scrollToBottom: $scrollToBottom,
            shouldShowGroupChatHeaders: true,
            inputView:  {
                
                InputView(
                    message: $message,
                    isEditing: $isEditing,
                    placeholder: "Type something",
                    onCommit: { messageKind in
                        if let currentChatUser = currentChatUser {
                            // get back to this
                            
                            DatabaseManager.shared.sendMessage(message: .init(user: currentChatUser,
                                                                              messageKind: messageKind,
                                                                              isSender: true),
                                                                              to: groupID)
                            
                            
                            
                        }
                        withAnimation(.spring(response: 0.2)) {
                            scrollToBottom = true
                        }
                    }
                )
                .padding(.leading, 10)
                .padding(.trailing, 20)
                .embedInAnyView()
                
                
                
            })
        
        
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
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                    ]
                )
            },
            set: { message in
                DispatchQueue.main.async {
                    self.message = message.string
                }
            }
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
        .foregroundColor(message.isEmpty ? .secondary : .white)
        .disabled(message.isEmpty)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                self.messageEditorView
                self.sendButton
            }
        }

   
    }
    
}


extension Color {
    static let chatBlue = Color(#colorLiteral(red: 0.1405690908, green: 0.1412397623, blue: 0.25395751, alpha: 1))
    static let chatSpotifyColor = Color(#colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 0.5))
    static let backdrop = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05))
    static let chatGray = Color(#colorLiteral(red: 0.7861273885, green: 0.7897668481, blue: 0.7986581922, alpha: 1))
}

let futuraFont = Font.custom("Futura", size: 17)

internal extension ChatMessageCellStyle {
    
    static let basicStyle = ChatMessageCellStyle(
        incomingTextStyle: .init(
            textStyle: .init(textColor: .white),
            textPadding: 12,
            attributedTextStyle: .init(textColor: .black),
            cellBackgroundColor: Color.backdrop,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
        ),
        outgoingTextStyle: .init(
            textStyle: .init(textColor: .white),
            textPadding: 12,
            cellBackgroundColor: Color.backdrop,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
            
        ),
        incomingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 5,
                                                     shadowColor: Color.clear)),
        outgoingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 5,
                                                     shadowColor: Color.clear))
    )
    
}
