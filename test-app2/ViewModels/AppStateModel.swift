//
//  ConversationsViewModel.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation
import FirebaseAuth
import MessageKit
import SwiftUI
import FirebaseAuth

class AppStateModel: ObservableObject {
    

    
    
    // @Published private(set) var conversations = [Conversation]()
    // @Published var messages = [String: [Message]]()
    
    @Published private(set) var isSignedIn = AuthManager.shared.isSignedIn
    @Published private(set) var isSigningIn = false
    
    @Published private(set) var users = [Message.ChatUserItem]()
    @Published var messages = [Message.ChatMessageItem]()
    @Published var currentRoom: String?
    
    @Published var chatUserDisplayCircles: [ChatUserDisplayCircle] = []

    
    
    /*
    var currentChatUser: Message.ChatUserItem? {
        return Message.ChatUserItem(userName: currentUsername, avatarURL: Auth.auth().currentUser?.photoURL, avatar: nil)
    }
    */
    
    init() {

        if isSignedIn {
            listenForMessages()
        }
    }
    
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }

        return WebView(url: url) { [weak self] success, didStartAuthFlow in
            DispatchQueue.main.async {
                self?.isSignedIn = success
                self?.isSigningIn = didStartAuthFlow
            }
            
        }
    }
    
    func signOut() {
        AuthManager.shared.signOut()
        isSignedIn = false
    }
    

    
}


//MARK: - User related / Match-making

extension AppStateModel {
    /*
     
     func loadUsers() {
         DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
             switch result {
             case .success(let usersCollection):
                 self?.users = usersCollection
             case.failure(let error):
                 print("failed to get users: \(error)")
             }
             
         })
     }
     
     
     */

    
    private func loadMatchingUsers() {
        // match making algorithm
    }


}



//MARK: - Conversations


extension AppStateModel {

    private func listenForMessages() {
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {

            case .success(let room):
                // stop listening for conversations in the previous room
                if let currentRoom = self?.currentRoom {
                    DatabaseManager.shared.removeMessagesObserver(for: currentRoom)
                }
                
                self?.currentRoom = room
                
                // empty messages since the room has changed
                self?.messages = []
                
                // update users

                DatabaseManager.shared.getAllUsers(completion: { result in
                    switch result {
                    case .success(let allUsers):
                        self?.users = allUsers
                        // this needs to be update as well
                        self?.makeCircles()
                        print(self?.users.count)
                        print(self?.chatUserDisplayCircles.count)
                        print(self?.chatUserDisplayCircles)
                    case .failure(_):
                        print("failed to get users in new room")
                    }
                })
                
 
                // get messages in new room
                DatabaseManager.shared.listenForMessages(in: room) { result in
                    switch result {
                    case .success(let newMessage):
                        self?.messages += newMessage
                    case .failure(_):
                        print("failed to get message")
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
}


//MARK: - Users map (rendering)

extension AppStateModel {
    
    struct ChatUserDisplayCircle: Identifiable {
        var user: Message.ChatUserItem? = nil

        let id = UUID()
        let intialCenter: CGPoint
        var center: CGPoint
        var dragTranslation: CGPoint? = .zero
        var alternateCenter: CGPoint {
            CGPoint(x: (center.x + (dragTranslation?.x ?? 0)) * 2 - 1, y: (center.y + (dragTranslation?.y ?? 0)) * 2 - 1) // -1, -1 to 1, 1 range
        }
        var diplayCenter: CGPoint {
            let isTranslatedPointInsideFrame = CGRect(origin: .zero, size: CGSize(width: 1, height: 1)).insetBy(dx: 0.01, dy: 0.01).contains(CGPoint(x: center.x + (dragTranslation?.x ?? 0), y: center.y + (dragTranslation?.y ?? 0)))
            
            return CGPoint(x: isTranslatedPointInsideFrame ?  center.x + (dragTranslation?.x ?? 0) : center.x,
                           y: isTranslatedPointInsideFrame ?  center.y + (dragTranslation?.y ?? 0) : center.y)
            
        }
        
        var radius: Double {
            sqrt(pow(alternateCenter.x, 2) + pow(alternateCenter.y, 2))
        }
        
        var scaleFactor: Double?
        
        var circleWidth: Double {
            Double(UIScreen.main.bounds.width) / 5
            
        }
    }

    
    var circlesAlongSides: Int {
        Int(ceil(sqrt(Double(users.count))))
        
    }
    
    var sizeMultiplier: Double {
        Double(circlesAlongSides) / 6
    }
    
    
    private func makeCircles() {
        print(circlesAlongSides)
        var grid: [CGPoint] = []
        for i in 0..<circlesAlongSides {
            for j in 0..<circlesAlongSides {
                let gapBetweenCols = 1.0 / Double(circlesAlongSides)
        
                if circlesAlongSides > 1 {
                    let x = Double(i) / Double(circlesAlongSides - 1)
                    let y = (Double(j) / Double(circlesAlongSides - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0)

                    
                    
                    grid.append(CGPoint(x: (x - 0.5) * sizeMultiplier + 0.5,
                                        y: (y - 0.5) * sizeMultiplier + 0.5))
       
                } else {
                    grid.append(CGPoint(x: 0.5,
                                        y: 0.5))
                    
                }


            }
        }
        
        
        print(grid)
        chatUserDisplayCircles = grid.map { ChatUserDisplayCircle(intialCenter: $0, center: $0) }
        // update scale
        for (index, _) in chatUserDisplayCircles.enumerated() {
            updateScaleOfCircle(with: index)
        }
        
        print(chatUserDisplayCircles)
        
        chatUserDisplayCircles = chatUserDisplayCircles.sorted { $0.radius < $1.radius }
        
        for (index, _) in chatUserDisplayCircles.enumerated() {
            if index < users.count  {
                chatUserDisplayCircles[index].user = users[index]
            }
          
        }
    }
    
    
    
    private func updateScaleOfCircle(with index: Int) {
        let x = chatUserDisplayCircles[index].center.x + (chatUserDisplayCircles[index].dragTranslation?.x ?? 0)
        let y = chatUserDisplayCircles[index].center.y + (chatUserDisplayCircles[index].dragTranslation?.y ?? 0)

        let isNearBorder = !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .inset(by: UIEdgeInsets(top: 0.2 , left: 0.2, bottom: 0.2, right: 0.2))
            .contains(CGPoint(x: x, y: y))
        
        let isAlmostAtBorder =  !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .inset(by: UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05))
            .contains(CGPoint(x: x, y: y))
        
        let isOutsideBorder = !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .contains(CGPoint(x: x, y: y))
        
        if isOutsideBorder {
            chatUserDisplayCircles[index].scaleFactor = 0
        } else if isAlmostAtBorder {
            chatUserDisplayCircles[index].scaleFactor = 0.05
        } else if isNearBorder {
            chatUserDisplayCircles[index].scaleFactor = max(1 - chatUserDisplayCircles[index].radius, 0)
        } else {
            chatUserDisplayCircles[index].scaleFactor = max(1 - chatUserDisplayCircles[index].radius, 0)
        }
    }
    
    func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
        // 0...1
        let xTranslation = value.translation.width / containerSize.width
        let yTranslation = value.translation.height / containerSize.width
        print(yTranslation)
        
        // update the centers
        for (index, _) in chatUserDisplayCircles.enumerated() {
            chatUserDisplayCircles[index].dragTranslation = CGPoint(x: xTranslation, y: yTranslation)
            updateScaleOfCircle(with: index)
        }
    }
    
    func processDragFinished(_ value: DragGesture.Value, containerSize: CGSize) {

            
        if (chatUserDisplayCircles.filter { $0.alternateCenter.x < -0.25 }).count  == chatUserDisplayCircles.count ||
            (chatUserDisplayCircles.filter { $0.alternateCenter.x > 0.25 }).count  == chatUserDisplayCircles.count ||
            (chatUserDisplayCircles.filter { $0.alternateCenter.y < -0.25 }).count  == chatUserDisplayCircles.count ||
            (chatUserDisplayCircles.filter { $0.alternateCenter.y > 0.25 }).count  == chatUserDisplayCircles.count  {

            for (index, _) in chatUserDisplayCircles.enumerated() {
                chatUserDisplayCircles[index].center = CGPoint(x: chatUserDisplayCircles[index].center.x,
                                                y: chatUserDisplayCircles[index].center.y)
                chatUserDisplayCircles[index].dragTranslation = .zero
                updateScaleOfCircle(with: index)
            }
            
        } else {
            for (index, _) in chatUserDisplayCircles.enumerated() {
               // setCircleSize()
     
                chatUserDisplayCircles[index].center = CGPoint(x: chatUserDisplayCircles[index].center.x + (chatUserDisplayCircles[index].dragTranslation?.x ?? 0),
                                                y: chatUserDisplayCircles[index].center.y + (chatUserDisplayCircles[index].dragTranslation?.y ?? 0))
                chatUserDisplayCircles[index].dragTranslation = .zero
                updateScaleOfCircle(with: index)
            }
        }
    }
    
    func recenter() {
        for (index, _) in chatUserDisplayCircles.enumerated() {
            chatUserDisplayCircles[index].center = chatUserDisplayCircles[index].intialCenter
            chatUserDisplayCircles[index].dragTranslation = .zero
            updateScaleOfCircle(with: index)
            
        }
        
    }
    /// 0 <= x <= 1
    private func easeOutSine(_ x: Double) -> Double {
        
        return sin(x * Double.pi / 2)
        
    }
    
}


