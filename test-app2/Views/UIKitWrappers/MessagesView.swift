//
//  MessagesView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 05.05.22.
//


import MessageKit
import SwiftUI
import InputBarAccessoryView
import FirebaseAuth


final class MessageSwiftUIVC: MessagesViewController {
    
    @Binding var messages: [Message]
    
    let otherUser: ChatUser
    var conversationID: String?
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // Because SwiftUI wont automatically make our controller the first responder, we need to do it on viewDidAppear
        becomeFirstResponder()
        
        
        
        messagesCollectionView.scrollToLastItem(animated: true)

//        if let conversationID = conversationID {
//            listenForMessages(id: conversationID)
//        }
//
        
    }
    
    
    
    init(messages: Binding<[Message]>,  conversationID: String?, otherUser: ChatUser) {
        
        self._messages = messages
        // print("in coordinator init", self._messages)
        self.conversationID = conversationID
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                DispatchQueue.main.async {
                    self?.messages = messages
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
                

            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    

        
}


@available(iOS 13.0, *)
struct MessagesView: UIViewControllerRepresentable {
    
    @State var initialized = false
    @Binding var messages : [Message]
    let otherUser: ChatUser
    var conversationID: String?

    
    func makeUIViewController(context: Context) -> MessagesViewController {

 
        let messagesVC = MessageSwiftUIVC(messages: $messages, conversationID: conversationID, otherUser: otherUser)
        messagesVC.messagesCollectionView.messagesDisplayDelegate = context.coordinator
        messagesVC.messagesCollectionView.messagesLayoutDelegate = context.coordinator
        messagesVC.messagesCollectionView.messagesDataSource = context.coordinator
        messagesVC.messageInputBar.delegate = context.coordinator
        messagesVC.scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        messagesVC.maintainPositionOnKeyboardFrameChanged = true // default false
        messagesVC.showMessageTimestampOnSwipeLeft = true // default false

        
        
        return messagesVC
    }

    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
        uiViewController.messagesCollectionView.reloadData()
        scrollToBottom(uiViewController)
    }
    
    private func scrollToBottom(_ uiViewController: MessagesViewController) {
        DispatchQueue.main.async {
            // The initialized state variable allows us to start at the bottom with the initial messages without seeing the initial scroll flash by
            uiViewController.messagesCollectionView.scrollToLastItem(animated: self.initialized)
            self.initialized = true
        }
    }
    

    
    
    func makeCoordinator() -> Coordinator {
        

        return Coordinator(messages: $messages, conversationID: conversationID, otherUser: otherUser)
    }
    
    
    final class Coordinator {
        
        public static let dateFormatter: DateFormatter = {
            let formattre = DateFormatter()
            formattre.dateStyle = .long
            formattre.locale = .current
            return formattre
        }()
        
        @Binding var messages: [Message]
        
        let otherUser: ChatUser
        var conversationID: String?
        
        private var sender: Sender? {
            guard let currentUserID = Auth.auth().currentUser?.uid,
                  let currentUserName = Auth.auth().currentUser?.displayName else {
                return nil
            }
            return Sender(senderId: currentUserID, photoURL: Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
                          displayName: currentUserName)
        }

        
        init(messages: Binding<[Message]>,  conversationID: String?, otherUser: ChatUser) {

            self._messages = messages
            print("in coordinator init", self._messages)
            self.conversationID = conversationID
            self.otherUser = otherUser
            
        }
        
    }

}



@available(iOS 13.0, *)
extension MessagesView.Coordinator: MessagesDataSource {
    func currentSender() -> SenderType {
        if let sender = sender {
            return sender
        }

        fatalError("Self Sender is nil, email should be cached")

    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count
    }
    
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    
        return NSAttributedString(string: sender?.displayName ?? "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = Self.dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let sentDate = message.sentDate
        let sentDateString = MessageKitDateFormatter.shared.string(from: sentDate)
        let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
        let timeLabelColor: UIColor = .systemGray
        return NSAttributedString(string: sentDateString, attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor])
    }
}

@available(iOS 13.0, *)

extension MessagesView.Coordinator: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // let message = MockMessage(text: text, user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date())
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let sender = sender,
            let messageId = createMessageId() else {
                return
        }

        print("Sending: \(text)")
        
        let message = Message(sender: sender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(text))

        // Send Message
        if conversationID == nil {
            // create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUser.id, otherUserName: otherUser.name, firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    let newConversationID = "conversation_\(message.messageId)"
                    // self?.listenForMessages(id: newConversationID)
                    
                    inputBar.inputTextView.text = ""
                }
                else {
                    print("failed ot send")
                }
            })
        } else {
            guard let conversationID = conversationID else {
                return
            }

            // append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserID: otherUser.id, otherUserName: otherUser.name, newMessage: message, completion: { success in
                if success {
                    inputBar.inputTextView.text = ""
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUesrEmail, senderEmail, randomInt
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return nil
        }

        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUser.id)_\(currentUserID)_\(dateString)"

        print("created message id: \(newIdentifier)")

        return newIdentifier
    }
    
    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                DispatchQueue.main.async {
                    self?.messages = messages
                }
               
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    
    
}

@available(iOS 13.0, *)
extension MessagesView.Coordinator: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        //avatarView.set(avatar: avatar)
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

