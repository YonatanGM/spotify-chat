//
//  Chat.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import SwiftUI


/*
struct Chat: View {
    @EnvironmentObject var model: AppStateModel

    
    let otherUser: Message.ChatUserItem
    @State var conversationID: String?
    @State private var conversationExistsClosureDone = false
    

  

    var body: some View {
        

            VStack {
                if conversationExistsClosureDone {
                    MessagesView(messages: Binding<[Message]>(
                        get: {
                            if let conversationID = conversationID {
                                return model.messages[conversationID] ?? []
                            } else {
                                return []
                            }
                    }, set: {
                        if let conversationID = conversationID {
                            model.messages[conversationID] = $0
                        }
                    }), otherUser: otherUser, conversationID: conversationID)
                    
                } else {
                    
                    ProgressView("wait")
                    
                    
                }

            }
        

        .onAppear {
     
            model.conversationExists(with: otherUser) { result in
                switch result {
                case .success(let id):
                    conversationID = id
                case .failure(_):
                    break
                }
                conversationExistsClosureDone = true
                
            }
        }
       
    }
    
 

//    private func listenForMessages(id: String) {
//        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { result in
//            switch result {
//            case .success(let messages):
//                print("success in getting messages: \(messages)")
//                guard !messages.isEmpty else {
//                    print("messages are empty")
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.messages = messages
//                }
//               
//            case .failure(let error):
//                print("failed to get messages: \(error)")
//            }
//        })
//    }
}

*/
//struct Chat_Previews: PreviewProvider {
//    static var previews: some View {
//        Chat()
//    }
//}
