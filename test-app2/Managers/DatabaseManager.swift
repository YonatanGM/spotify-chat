//
//  DatabaseManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 30.04.22.
//

import Foundation

import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import MessageKit
import CoreGraphics

class DatabaseManager {
    
    
    static let shared = DatabaseManager()
    
    // private let database = Database.database().reference()
    private let database = Database.database(url: "http://localhost:9018?ns=testapp-79467-default-rtdb").reference()
    
    var messageHandles = [String: UInt]() // to unregister them
}


//MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with id: String, completion: @escaping ((Bool) -> Void )) {
        database.child("users/\(id)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard snapshot.exists(), snapshot.childrenCount > 3 else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// inserts new user to database
    public func insertUser(with profile: UserProfile, completion: @escaping ((Bool) ->Void)) {
        
        // set user's top tracks, artists & genres
            
        // top artist
        APICaller.shared.getTopArtists { [weak self] result in
            switch result {
            case .success(let response):
                // convert to json
                guard let data = try? JSONEncoder().encode(response), let topArtists = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(false)
                    return
                }
            
                    
                // top genres (based on genres of top artists)
                /*
                let topGenres =  response.items.compactMap { $0.genres }.reduce([]) {
                    return Set($0).union(Set($1))
                }
                */
                
                let topGenres = Set(Array(Set(["acoustic", "afrobeat", "alt-rock", "alternative", "ambient", "anime", "black-metal", "bluegrass", "blues", "bossanova", "brazil", "breakbeat", "british", "cantopop", "chicago-house", "children", "chill", "classical", "club", "comedy", "country", "dance", "dancehall", "death-metal", "deep-house", "detroit-techno", "disco", "disney", "drum-and-bass", "dub", "dubstep", "edm", "electro", "electronic", "emo", "folk", "forro", "french", "funk", "garage", "german", "gospel", "goth", "grindcore", "groove", "grunge", "guitar", "happy", "hard-rock", "hardcore", "hardstyle", "heavy-metal", "hip-hop", "holidays", "honky-tonk", "house", "idm", "indian", "indie", "indie-pop", "industrial", "iranian", "j-dance", "j-idol", "j-pop", "j-rock", "jazz", "k-pop", "kids", "latin", "latino", "malay", "mandopop", "metal", "metal-misc", "metalcore", "minimal-techno", "movies", "mpb", "new-age", "new-release", "opera", "pagode", "party", "philippines-opm", "piano", "pop", "pop-film", "post-dubstep", "power-pop", "progressive-house", "psych-rock", "punk", "punk-rock", "r-n-b", "rainy-day", "reggae", "reggaeton", "road-trip", "rock", "rock-n-roll", "rockabilly", "romance", "sad", "salsa", "samba", "sertanejo", "show-tunes", "singer-songwriter", "ska", "sleep", "songwriter", "soul", "soundtracks", "spanish", "study", "summer", "swedish", "synth-pop", "tango", "techno", "trance", "trip-hop", "turkish", "work-out", "world-music"])).prefix(20))
                
                // add new genres to genres array in the database
                self?.database.child("genres").observeSingleEvent(of: .value, with: { snapshot in
                    var allGenres = snapshot.value as? [String] ?? []
                    allGenres += Array(topGenres.subtracting(allGenres))
                    self?.database.child("genres").setValue(allGenres, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        APICaller.shared.getTopTracks { [weak self] result in
                            switch result {
                            case .success(let response):
                                // convert to json
                                guard let data = try? JSONEncoder().encode(response), let topTracks = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                                    completion(false)
                                    return
                                }
                                
                                // create user
                                print("creating user")
                                print(response.items.map {$0.name}, topGenres)
                                self?.database.child("users/\(profile.id)").setValue([
                                    "name": profile.display_name,
                                    "email": profile.email,
                                    "profile_picture": profile.images.first?.url,
                                    "top_artists": topArtists,
                                    "top_genres": Array(topGenres),
                                    "top_tracks": topTracks
                                ].compactMapValues { $0 }, withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("failed to write to database")
                                        completion(false)
                                        return
                                    }
                                    completion(true)
                                })
                                    
                            case .failure( _):
                                completion(false)
                                
                            }
  
                        }
                    })

                })
            case .failure(_):
                completion(false)
                
            }
            
        }
        
    }
    
    public func getAllUsers(completion: @escaping (Result<[ChatUser], Error>) -> Void) {
        database.child("users").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let users: [ChatUser] = value.compactMap { user in
                guard let id = user["id"],
                      let name = user["name"] else {
                    return nil
                }
                return ChatUser(id: id, name: name, email: user["email"], profile_picture: user["profile_picture"])
            }
            completion(.success(users))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
                                            
}


// MARK: - Group Chat

extension DatabaseManager {
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    
    public func sendMessage(message: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUserName = Auth.auth().currentUser?.displayName else {
                completion(false)
                return
        }
        
        var messageContent = ""
        let dateString = Self.dateFormatter.string(from: message.sentDate)
        switch message.kind {
        case .text(let messageText):
            messageContent = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                messageContent = targetUrlString
            }
            break
        case .video(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                messageContent = targetUrlString
            }
            break
        case .location(let locationData):
            let location = locationData.location
            messageContent = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_), .linkPreview(_):
            break
        }
        

        var newMessageRef = database.child("room/conversations").childByAutoId()
        let newMessage: [String: Any] = [
            "id": newMessageRef.key,
            "type": message.kind.messageKindString,
            "content": messageContent,
            "date": dateString,
            "sender_id": currentUserID,
            "is_read": false
        ]
        
        newMessageRef.setValue(newMessage, withCompletionBlock: { [weak self] error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public func fetchMessages(in roomID: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        let numOfMessagesToFetch: UInt = 100
        var messages: [Message] = []
        database.child("room/conversations").queryLimited(toLast: numOfMessagesToFetch).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let messageSnapshot = enumerator.nextObject() as? DataSnapshot {
                if let dictionary = messageSnapshot.value as? [String: Any],
                   let isRead = dictionary["is_read"] as? Bool,
                   let messageID = dictionary["id"] as? String,
                   let content = dictionary["content"] as? String,
                   let senderID = dictionary["sender_id"] as? String,
                   let type = dictionary["type"] as? String,
                   let dateString = dictionary["date"] as? String,
                   let date = Self.dateFormatter.date(from: dateString)
                {
                    
                    var kind: MessageKind?
                    // won't be supporting photo/video/audio
                    // location seems useful
                    if type == "location" {
                        let locationComponents = content.components(separatedBy: ",")
                        if let longitude = Double(locationComponents[0]),
                           let latitude = Double(locationComponents[1]) {
                            // print("Rendering location; long=\(longitude) | lat=\(latitude)")
                            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                                    size: CGSize(width: 300, height: 300))
                            kind = .location(location)
                        }
                        
                    } else if type == "text" {
                        kind = .text(content)
                    }

                    // kind is not known
                    if let finalKind = kind {
                        
                        let sender = Sender(senderId: senderID, photoURL: "",
                                            displayName: "")
                        messages.append(Message(sender: sender,
                                                messageId: messageID,
                                                sentDate: date,
                                                kind: finalKind))
                        
                    }

                }
                    
            }
            completion(.success(messages))

        }, withCancel: { error in
            completion(.failure(error))
        })

    }
    
    public func listenForNewMessages(in roomID: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        let numOfMessagesToFetch: UInt = 100
        var messages: [Message] = []
        database.child("room/conversations").queryLimited(toLast: numOfMessagesToFetch).observe(.childAdded, with: { snapshot in
            let enumerator = snapshot.children
            while let messageSnapshot = enumerator.nextObject() as? DataSnapshot {
                if let dictionary = messageSnapshot.value as? [String: Any],
                   let isRead = dictionary["is_read"] as? Bool,
                   let messageID = dictionary["id"] as? String,
                   let content = dictionary["content"] as? String,
                   let senderID = dictionary["sender_id"] as? String,
                   let type = dictionary["type"] as? String,
                   let dateString = dictionary["date"] as? String,
                   let date = Self.dateFormatter.date(from: dateString)
                {
                    
                    var kind: MessageKind?
                    // won't be supporting photo/video/audio
                    // location seems useful
                    if type == "location" {
                        let locationComponents = content.components(separatedBy: ",")
                        if let longitude = Double(locationComponents[0]),
                           let latitude = Double(locationComponents[1]) {
                            // print("Rendering location; long=\(longitude) | lat=\(latitude)")
                            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                                    size: CGSize(width: 300, height: 300))
                            kind = .location(location)
                        }
                        
                    } else if type == "text" {
                        kind = .text(content)
                    }

                    // only text and location supported for now
                    if let finalKind = kind {
                        
                        let sender = Sender(senderId: senderID, photoURL: "",
                                            displayName: "")
                        messages.append(Message(sender: sender,
                                                messageId: messageID,
                                                sentDate: date,
                                                kind: finalKind))
                        
                    }
                }
            }
            completion(.success(messages))
        }, withCancel: { error in
            completion(.failure(error))
        })
    }
    
    public func listenForMessages(in roomID: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        let numOfMessagesToFetch: UInt = 100
        var messages: [Message] = []
        database.child("room/conversations").queryLimited(toLast: numOfMessagesToFetch).observe(.value, with: { snapshot in
            let enumerator = snapshot.children
            while let messageSnapshot = enumerator.nextObject() as? DataSnapshot {
                if let dictionary = messageSnapshot.value as? [String: Any],
                   let isRead = dictionary["is_read"] as? Bool,
                   let messageID = dictionary["id"] as? String,
                   let content = dictionary["content"] as? String,
                   let senderID = dictionary["sender_id"] as? String,
                   let type = dictionary["type"] as? String,
                   let dateString = dictionary["date"] as? String,
                   let date = Self.dateFormatter.date(from: dateString)
                {
                    
                    var kind: MessageKind?
                    // won't be supporting photo/video/audio
                    // location seems useful
                    if type == "location" {
                        let locationComponents = content.components(separatedBy: ",")
                        if let longitude = Double(locationComponents[0]),
                           let latitude = Double(locationComponents[1]) {
                            // print("Rendering location; long=\(longitude) | lat=\(latitude)")
                            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                                    size: CGSize(width: 300, height: 300))
                            kind = .location(location)
                        }
                        
                    } else if type == "text" {
                        kind = .text(content)
                    }

                    // only text and location supported for now
                    if let finalKind = kind {
                        
                        let sender = Sender(senderId: senderID, photoURL: "",
                                            displayName: "")
                        messages.append(Message(sender: sender,
                                                messageId: messageID,
                                                sentDate: date,
                                                kind: finalKind))
                        
                    }
                }
            }
            completion(.success(messages))

        }, withCancel: { error in
            completion(.failure(error))
        })
    }
}







// TODO: Remove 
// MARK: - Sending messages / conversations ** two people only

extension DatabaseManager {

    /*
        "dfsdfdsfds" {
            "messages": [
                {
                    "id": String,
                    "type": text, photo, video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "isRead": true/false,
                }
            ]
        }

           conversaiton => [
              [
                  "conversation_id": "dfsdfdsfds"
                  "other_user_email":
                  "latest_message": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read": true/false
                  }
              ],
            ]
           */


    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserID: String, otherUserName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUserName = Auth.auth().currentUser?.displayName else {
                return
        }
        
        let ref = database.child("\(currentUserID)")

        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }

            let messageDate = firstMessage.sentDate
            let dateString = Self.dateFormatter.string(from: messageDate)

            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }

            let conversationId = "conversation_\(firstMessage.messageId)"

            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_id": otherUserID,
                "other_user_name": otherUserName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_id": currentUserID,
                "other_user_name": currentUserName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            // Update recipient conversaiton entry

            self?.database.child("\(otherUserID)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversatoins = snapshot.value as? [[String: Any]] {
                    // append
                    conversatoins.append(recipient_newConversationData)
                    self?.database.child("\(otherUserID)/conversations").setValue(conversatoins)
                }
                else {
                    // create
                    self?.database.child("\(otherUserID)/conversations").setValue([recipient_newConversationData])
                }
            })

            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append

                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(otherUserName: otherUserName,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            else {
                // conversation array does NOT exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]

                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation(otherUserName: otherUserName,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        })
    }

    private func finishCreatingConversation(otherUserName: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text, photo, video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false,
//        }

        let messageDate = firstMessage.sentDate
        let dateString = Self.dateFormatter.string(from: messageDate)

        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_),.custom(_), .linkPreview(_):
            break
        }

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }


        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_id": currentUserID,
            "is_read": false,
            "other_user_name": otherUserName
        ]

        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        print("adding convo: \(conversationID)")

        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    /// Fetches and returns all conversations for the user with passed in id
    public func getAllConversations(for user: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
            database.child("\(user)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let otherUserName = dictionary["other_user_name"] as? String,
                    let otherUserID = dictionary["other_user_id"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }

                let latestMmessageObject = LatestMessage(date: date,
                                                         text: message,
                                                         isRead: isRead)
                return Conversation(id: conversationId,
                                    otherUserName: otherUserName,
                                    otherUserID: otherUserID,
                                    latestMessage: latestMmessageObject)
            })

            completion(.success(conversations))
        })
        
        
    }

    /// Gets all mmessages for a given conversatino
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        messageHandles[id] = database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let messages: [Message] = value.compactMap({ dictionary in
                guard let otherUserName = dictionary["other_user_name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderID = dictionary["sender_id"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = Self.dateFormatter.date(from: dateString)else {
                        return nil
                }
                var kind: MessageKind?
                
                // won't be supporting photo/video/audio
                // location seems useful
                if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponents[0]),
                        let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    print("Rendering location; long=\(longitude) | lat=\(latitude)")
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }

                guard let finalKind = kind else {
                    return nil
                }

                let sender = Sender(senderId: senderID, photoURL: "",
                                    displayName: otherUserName)

                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })

            completion(.success(messages))
        })

    }

    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserID: String, otherUserName: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        // update sender latest message
        // update recipient latest message

   

        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }

            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }

            let messageDate = newMessage.sentDate
            let dateString = Self.dateFormatter.string(from: messageDate)

            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }

            guard let currentUserID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }

         

            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_id": currentUserID,
                "is_read": false,
                "other_user_name": otherUserName
            ]

            currentMessages.append(newMessageEntry)

            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }

                strongSelf.database.child("\(currentUserID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]

                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0

                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }

                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_id": otherUserID,
                                "other_user_name": otherUserName,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_id": otherUserID,
                            "other_user_name": otherUserName,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }

                    strongSelf.database.child("\(currentUserID)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }


                        // Update latest message for recipient user

                        strongSelf.database.child("\(otherUserID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()

                            guard let currentUserName = Auth.auth().currentUser?.displayName else {
                                return
                            }

                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }

                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // failed to find in current colleciton
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_id": currentUserID,
                                        "other_user_name": currentUserName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            else {
                                // current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_id": currentUserID,
                                    "other_user_name": currentUserName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }

                            strongSelf.database.child("\(otherUserID)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }

    public func deleteConversation(conversationID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
      

        print("Deleting conversation with id: \(conversationID)")

        // Get all conversations for current user
        // delete conversation in collection with target id
        // reset those conversations for the user in database
        let ref = database.child("\(currentUserID)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationID {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }

                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _  in
                    guard error == nil else {
                        completion(false)
                        print("faield to write new conversatino array")
                        return
                    }
                    print("deleted conversaiton")
                    completion(true)
                })
            }
        }
    }

    public func conversationExists(with recipientID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        
        guard let senderID = Auth.auth().currentUser?.uid else {
            return
        }
     
        database.child("\(recipientID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderID = $0["other_user_id"] as? String else {
                    return false
                }
                return senderID == targetSenderID
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.success(nil))
                    return
                }
                completion(.success(id))
                return
            }

            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }

}
