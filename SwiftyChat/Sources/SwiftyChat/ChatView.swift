//
//  ChatView.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI
import SwiftUIEKtensions

public struct ChatView<Message: ChatMessage, User: ChatUser>: View {
    
    private var messages: [Message]
    private var inputView: () -> AnyView
    
    private var onMessageCellAppeared: (Message) -> Void = { _ in }
    private var onMessageCellTapped: (Message) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (Message) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterSection: (ContactItem, Message) -> [ContactCellButton] = { _, _ in [] }
    private var onAttributedTextTappedCallback: () -> AttributedTextTappedCallback = { return AttributedTextTappedCallback() }
    private var onCarouselItemAction: (CarouselItemButton, Message) -> Void = { (_, _) in }
    
    public var onAvatarTapped: ((Message.User) -> Void)?
    
    private var inset: EdgeInsets
    private var dateFormater: DateFormatter = DateFormatter()
    private var dateHeaderTimeInterval: TimeInterval
    private var shouldShowGroupChatHeaders: Bool
    
    @Binding private var scrollToBottom: Bool
    @State private var isKeyboardActive = false
    
    @State private var contentSizeThatFits: CGSize = .zero
    private var messageEditorHeight: CGFloat {
        min(
            contentSizeThatFits.height,
            0.25 * UIScreen.main.bounds.height
        )
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                chatView(in: geometry)
                    .padding(.top, 2 * messageEditorHeight)
            }
//            .background(Color.red)
            .offset(y: -messageEditorHeight - 10)
            .clipped()
            .mask(LinearGradient(gradient: Gradient(colors: [.black, .clear]),
                                 startPoint: .init(x: 0.5, y: 1 - (messageEditorHeight + 10) * 2  / geometry.size.height),
                                 endPoint:  .init(x: 0.5, y: 1 - (messageEditorHeight + 10)  / geometry.size.height)))
 
            
            .overlay(

                
                inputView()
                    .onPreferenceChange(ContentSizeThatFitsKey.self) {
                        contentSizeThatFits = $0
                    }
                    
                    .frame(height: messageEditorHeight + 10)
               
                    // .background(Color.white.blendMode(.destinationOver))
                , alignment: .bottom)
                // PIPVideoCell<Message>()
            .iOS { $0.keyboardAwarePadding() }
        }
        .padding(.bottom)
        .environmentObject(DeviceOrientationInfo())
        .environmentObject(VideoManager<Message>())
        .edgesIgnoringSafeArea(.bottom)
        .iOS { $0.dismissKeyboardOnTappingOutside() }
    }
    
    @ViewBuilder private func chatView(in geometry: GeometryProxy) -> some View {
        
        ScrollViewReader { proxy in
            LazyVStack {
                ForEach(messages) { message in
                    let showDateheader = shouldShowDateHeader(
                        messages: messages,
                        thisMessage: message
                    )
                    let shouldShowDisplayName = shouldShowDisplayName(
                        messages: messages,
                        thisMessage: message,
                        dateHeaderShown: showDateheader
                    )
                    
                    if showDateheader {
                        Text(dateFormater.string(from: message.date))
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                    
                    if shouldShowDisplayName {
                        Text(message.user.userName)
                            .font(.footnote)
                            .multilineTextAlignment(.trailing)
                            .frame(
                                maxWidth: geometry.size.width * (UIDevice.isLandscape ? 0.6 : 0.75),
                                minHeight: 1,
                                alignment: message.isSender ? .trailing: .leading
                            )
                    }
                    chatMessageCellContainer(in: geometry.size, with: message, with: shouldShowDisplayName)
                }
                Spacer()
                    .frame(height: 100)
                    .id("bottom")
                    
                   
            }
            .padding(.bottom, 100)
            .foregroundColor(.white)
            // .padding(EdgeInsets(top: inset.top, leading: inset.leading, bottom: 0, trailing: inset.trailing))
            .onChange(of: scrollToBottom) { value in
                if value {
                    withAnimation(.easeIn(duration: 0.2)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        scrollToBottom = false
                    }
                }
            }
            .onAppear {
                proxy.scrollTo("bottom", anchor: .bottom)
                /*
                DispatchQueue.main.async() {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
                */
            }
            .iOS {
                // Auto Scroll with Keyboard Notification
                $0.onReceive(
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                        .debounce(for: .milliseconds(400), scheduler: RunLoop.main),
                    perform: { _ in
                        if !isKeyboardActive {
                            isKeyboardActive = true
                            scrollToBottom = true
                        }
                    }
                )
                .onReceive(
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                    perform: { _ in isKeyboardActive = false }
                )
            }
        }
        .padding(.bottom, 200)
    
    }
    
}

internal extension ChatView {
    // MARK: - List Item
    private func chatMessageCellContainer(
        in size: CGSize,
        with message: Message,
        with avatarShow: Bool
    ) -> some View {
        ChatMessageCellContainer(
            message: message,
            size: size,
            onMessageCellAppeared: onMessageCellAppeared,
            onQuickReplyItemSelected: onQuickReplyItemSelected,
            contactFooterSection: contactCellFooterSection,
            onTextTappedCallback: onAttributedTextTappedCallback,
            onCarouselItemAction: onCarouselItemAction
        )
        .onAppear { onMessageCellAppeared(message) }
        .onTapGesture { onMessageCellTapped(message) }
        .contextMenu(menuItems: { messageCellContextMenu(message) })
        .modifier(
            AvatarModifier<Message, User>(
                message: message,
                showAvatarForMessage: shouldShowAvatarForMessage(
                    forThisMessage: avatarShow
                ),
                onAvatarTapped: onAvatarTapped
            )
        )
        .modifier(MessageHorizontalSpaceModifier(messageKind: message.messageKind, isSender: message.isSender))
        .modifier(CellEdgeInsetsModifier(isSender: message.isSender))
        .id(message.id)
    }
}

public extension ChatView {
    func shouldShowDateHeader(messages: [Message], thisMessage: Message) -> Bool {
        if let messageIndex = messages.firstIndex(where: { $0.id == thisMessage.id }) {
            if messageIndex == 0 { return true }
            let prevMessage = messages[messageIndex]
            let currMessage = messages[messageIndex - 1]
            let timeInterval = prevMessage.date - currMessage.date
            return timeInterval > dateHeaderTimeInterval
        }
        return false
    }
    
    func shouldShowDisplayName(
        messages: [Message],
        thisMessage: Message,
        dateHeaderShown: Bool
    ) -> Bool {
        if !shouldShowGroupChatHeaders {
            return false
        } else if dateHeaderShown {
            return true
        }
        
        if let messageIndex = messages.firstIndex(where: { $0.id == thisMessage.id }) {
            if messageIndex == 0 { return true }
            let prevMessageUserID = messages[messageIndex].user.id
            let currMessageUserID = messages[messageIndex - 1].user.id
            return !(prevMessageUserID == currMessageUserID)
        }
        
        return false
    }
    
    func shouldShowAvatarForMessage(forThisMessage: Bool) -> Bool {
        (forThisMessage || !shouldShowGroupChatHeaders)
    }
}

// MARK: - Initializers
public extension ChatView {
    /// ChatView constructor
    /// - Parameters:
    ///   - messages: Messages to display
    ///   - scrollToBottom: set to `true` to scrollToBottom
    ///   - dateHeaderTimeInterval: Amount of time between messages in
    ///                             seconds required before dateheader added
    ///                             (Default 1 hour)
    ///   - shouldShowGroupChatHeaders: Shows the display name of the sending
    ///                                 user only if it is the first message in a chain.
    ///                                 Also only shows avatar for first message in chain.
    ///                                 (disabled by default)
    ///   - inputView: inputView view to provide message
    ///   
    init(
        messages: [Message],
        onMessageCellAppeared: @escaping (Message) -> Void,
        scrollToBottom: Binding<Bool> = .constant(false),
        dateHeaderTimeInterval: TimeInterval = 3600,
        shouldShowGroupChatHeaders: Bool = false,
        onAvatarTapped: ((Message.User) -> Void)?,
        inputView: @escaping () -> AnyView,
        inset: EdgeInsets = .init()
    ) {
        self.messages = messages
        self.inputView = inputView
        _scrollToBottom = scrollToBottom
        self.inset = inset
        self.dateFormater.dateStyle = .medium
        self.dateFormater.timeStyle = .short
        self.dateFormater.timeZone = NSTimeZone.local
        self.dateFormater.doesRelativeDateFormatting = true
        self.dateHeaderTimeInterval = dateHeaderTimeInterval
        self.shouldShowGroupChatHeaders = shouldShowGroupChatHeaders
        
        self.onMessageCellAppeared = onMessageCellAppeared
        self.onAvatarTapped = onAvatarTapped
        
    }
}

public extension ChatView {

    func onMessageCellAppeared(_ action: @escaping (Message) -> Void) -> Self {
        then({ $0.onMessageCellAppeared = action })
    }
    /// Triggered when a ChatMessage is tapped.
    func onMessageCellTapped(_ action: @escaping (Message) -> Void) -> Self {
        then({ $0.onMessageCellTapped = action })
    }
    
    /// Present ContextMenu when a message cell is long pressed.
    func messageCellContextMenu(_ action: @escaping (Message) -> AnyView) -> Self {
        then({ $0.messageCellContextMenu = action })
    }
    
    /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
    func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> Self {
        then({ $0.onQuickReplyItemSelected = action })
    }
    
    /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
    func contactItemButtons(_ section: @escaping (ContactItem, Message) -> [ContactCellButton]) -> Self {
        then({ $0.contactCellFooterSection = section })
    }
    
    /// To listen text tapped events like phone, url, date, address
    func onAttributedTextTappedCallback(action: @escaping () -> AttributedTextTappedCallback) -> Self {
        then({ $0.onAttributedTextTappedCallback = action })
    }
    
    /// Triggered when the carousel button tapped.
    func onCarouselItemAction(action: @escaping (CarouselItemButton, Message) -> Void) -> Self {
        then({ $0.onCarouselItemAction = action })
    }
}
