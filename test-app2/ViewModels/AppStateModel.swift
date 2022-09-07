//
//  ConversationsViewModel.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseAuth
import Combine
import SpriteKit
import SwiftyChat



class AppStateModel: ObservableObject {
    
    enum SignInStatus {
        case signedIn
        case signingIn
        case notDetermined
        case signedOut
    }
    
    @Published private(set) var signInStatus: SignInStatus = .notDetermined
    
    @Published private(set) var users = [Message.ChatUserItem]()
    @Published private(set) var usersInCurrentRoom = [Message.ChatUserItem]()
    @Published var messages = [Message.ChatMessageItem]()
    @Published var currentRoom: String?
    
    // @Published var chatUserDisplayCircles: [ChatUserDisplayCircle] = []
    private var cancellables = Set<AnyCancellable>()
    
    @Published var skBg = { () -> SKScene in 
        let scene = SKScene()
        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        return scene
    }()


    
    init() {
        
        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                self?.listenForMessages()
            }
        })
        .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            AuthManager.shared.currentUser = user
            if AuthManager.shared.isSignedIn {
                AuthManager.shared.refreshIfNeeded()
                self?.signInStatus = .signedIn
            } else {
                DatabaseManager.shared.removeRoomChangeObserver()
                self?.signInStatus = .signedOut
            }
        }

    }
    
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }
        return WebView(url: url) { [weak self] success, didStartAuthFlow in
            DispatchQueue.main.async {
                self?.signInStatus = didStartAuthFlow ? .signingIn : (success ? .signedIn : .signedOut)
            }
        }
    }
    
    
    func signOut() {
        AuthManager.shared.signOut()
        signInStatus = .signedOut
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
                    DatabaseManager.shared.removeMessagesObserver(currentRoom)
                }
                
                self?.currentRoom = room
                
                // empty messages since the room has changed
                self?.messages = []
                
                // remove old users
                self?.usersInCurrentRoom = []
                
                // update the users
                DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        self?.usersInCurrentRoom = users
                    case .failure(_):
                        print("failed to get users in new room")
                    }
                    
                })
                /*
                DatabaseManager.shared.getAllUsers(completion: { result in
                    switch result {
                    case .success(let allUsers):
                        self?.users = allUsers
                        for i in 0..<20 {
                            self?.users.append(Message.ChatUserItem(userName: UUID().uuidString,
                                                                    avatarURL: URL(string: ""),
                                                                    avatar: nil,
                                                                    id: UUID().uuidString,
                                                                    additionalInfo: ["top_artist": String(UUID().uuidString.prefix(10)),
                                                                                     "top_track": String(UUID().uuidString.prefix(10))]))
                        }
                        
                        
                        // this needs to be updated as well
                        self?.makeCircles()
                        self?.makeBg()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            // stop BG simulation
                            // self?.stopBgSimulation()
                            
                        }
                    case .failure(_):
                        c
                    }
                })
                */
 
                // get messages in the new room
                DatabaseManager.shared.listenForMessages(in: room) { result in
                    switch result {
                    case .success(let newMessage):
                        self?.messages.append(newMessage)
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
/*
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
    
            return CGPoint(x: isTranslatedPointInsideFrame ? center.x + (dragTranslation?.x ?? 0) : center.x,
                           y: isTranslatedPointInsideFrame ? center.y + (dragTranslation?.y ?? 0) : center.y)
            
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
        // print(circlesAlongSides)
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
        
        chatUserDisplayCircles = grid.map { ChatUserDisplayCircle(intialCenter: $0, center: $0) }
        // update scale
        for (index, _) in chatUserDisplayCircles.enumerated() {
            updateScaleOfCircle(with: index)
        }
        
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
        
        // updateBg()
    }
    
    func processDragFinished(_ value: DragGesture.Value, containerSize: CGSize) {

            
        if (chatUserDisplayCircles.filter { $0.alternateCenter.x < -0.25 }).count  == chatUserDisplayCircles.count ||
            (chatUserDisplayCircles.filter { $0.alternateCenter.x > 0.25 }).count  == chatUserDisplayCircles.count ||
            (chatUserDisplayCircles.filter { $0.alternateCenter.y < -0.25 }).count == chatUserDisplayCircles.count ||
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
        
        updateBg()
    }
    
    func recenter() {
        for (index, _) in chatUserDisplayCircles.enumerated() {
            chatUserDisplayCircles[index].center = chatUserDisplayCircles[index].intialCenter
            chatUserDisplayCircles[index].dragTranslation = .zero
            updateScaleOfCircle(with: index)
            
        }
        
        // updateBg()
    }
    
    private func makeBg() {
        skBg.removeAllChildren()
        guard let containerSize = skBg.scene?.size else {
            return
        }
        
        let edgeNode = SKShapeNode(rect: skBg.frame)
        edgeNode.physicsBody = SKPhysicsBody(edgeLoopFrom: skBg.frame)
        edgeNode.strokeColor = .clear
        // skBg.addChild(edgeNode)
        
        chatUserDisplayCircles.prefix(20).forEach { circle in
            // top artist
       
            if let topArtist = circle.user?.additionalInfo["top_artist"] {
                let node = SKLabelNode(text:  topArtist)
                node.name = circle.id.uuidString
                node.fontSize = Double.random(in: 5...20)
                node.position = circle.diplayCenter.applying(CGAffineTransform(scaleX: containerSize.width,
                                                                               y: containerSize.width))
                let physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
                
                physicsBody.isDynamic = true
                physicsBody.linearDamping = 5
                                
                physicsBody.affectedByGravity = false
                node.physicsBody = physicsBody
                node.alpha = Double.random(in: 0.25...0.5)
                skBg.addChild(node)
      
            }
            
            // top track
            
            if let topTrack = circle.user?.additionalInfo["top_track"] {
                let node = SKLabelNode(text:  topTrack)
                node.name = circle.id.uuidString
                node.fontSize = Double.random(in: 5...20)
                node.position = circle.diplayCenter.applying(CGAffineTransform(scaleX: containerSize.width,
                                                                               y: containerSize.width))
                let physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
                
                 physicsBody.linearDamping = 5
                physicsBody.isDynamic = true
                physicsBody.affectedByGravity = false
                node.physicsBody = physicsBody
                node.alpha = Double.random(in: 0.25...0.5)
                skBg.addChild(node)
            }
            


        }
    }
    
    private func updateBg() {
        let movementAmount = 0.1
        guard let containerSize = skBg.scene?.size else {
            return
        }
        chatUserDisplayCircles.forEach {
            
            
            if let pos = skBg.childNode(withName: $0.id.uuidString)?.position {
                let dx = $0.diplayCenter.applying(CGAffineTransform(scaleX: containerSize.width, y: containerSize.width)).x - pos.x
                let dy = $0.diplayCenter.applying(CGAffineTransform(scaleX: containerSize.width, y: containerSize.width)).y - pos.y
                
                skBg.childNode(withName: $0.id.uuidString)?.physicsBody?.applyImpulse(CGVector(dx: dx * movementAmount, dy: -dy * movementAmount))
            }
       
            
           
        }
    }
    
    private func stopBgSimulation() {
        skBg.children.forEach {
            $0.physicsBody?.isDynamic = false
        }
    }
    
    /// 0 <= x <= 1
    private func easeOutSine(_ x: Double) -> Double {
        return sin(x * Double.pi / 2)
    }
    
}
 */



