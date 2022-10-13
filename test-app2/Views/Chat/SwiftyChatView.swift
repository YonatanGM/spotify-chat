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
    
    @State var isTapping: Bool = false
    @Binding var showChat: Bool
    
    @State private var navigationControllerDefault: UINavigationController?
    
    @State private var navigationController: UINavigationController?
    
    var body: some View {
       
        if model.groups[groupID]?.isDm == false {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(model.groups[groupID]?.name ?? "")
                    // .font(.headline)
                        .padding(.top, -5)
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(
                    Color(.sRGB, red: 65 / 255, green: 65 / 255, blue: 65 / 255, opacity: 1)
                        .shadow(radius: 1)
                        .edgesIgnoringSafeArea(.top)
                )
                chatView
                
            }
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
                .edgesIgnoringSafeArea(.all)
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    
                    UserIconsToolbar(users: model.groups[groupID]?.users ?? [])
                        .frame(width: 150, height: 25)
                        .accessibilityAddTraits(.isHeader)
                    // .border(.red)
                }
            }
            .navigationBarItems(trailing:
                Menu {
                
                    if let currentUserID = AuthManager.shared.currentUser?.uid {
                        if currentUserID == model.groups[groupID]?.admin {
                            Button(role: .destructive, action: {
                                DatabaseManager.shared.deleteGroup(groupID) { success in
                                    if success {
                                        showChat = false
                                    }
                                }
                            }) {
                                Label("Delete group", systemImage: "trash")
                            }
                        } else {
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
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                    
                }
            )
        } else {
            chatView

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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            if let otherUser = model.groups[groupID]?.otherUser {
                                UserIcon(user: otherUser)
                                    .frame(height: 25)
                            }
                            Text(model.groups[groupID]?.otherUser?.name ?? "")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.leading, -10)
                        .foregroundColor(.white)
                    }
                }
                .navigationBarItems(trailing:
                    Menu {
                        Button(role: .destructive, action: {
                            DatabaseManager.shared.deleteGroup(groupID) { success in
                                if success {
                                    showChat = false
                                }
                            }
                        }) {
                            Label("Delete chat", systemImage: "trash")
                        }
                     
                    } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                    }
                )

        }
        
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
                        if let currentChatUser = model.currentUser {
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
            if !message.isEmpty && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.onCommit?(.text(message))
                self.message.removeAll()
            }
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

