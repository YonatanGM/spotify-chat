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
import CoreGraphics
import SwiftyChat

class DatabaseManager {
    
    
    static let shared = DatabaseManager()
    
    // private let database = Database.database().reference()
    private let database = Database.database(url: "http://localhost:5009?ns=testapp-79467-default-rtdb").reference()
    
    // var messageHandles = [String: UInt]() // to unregister them
    
}


//MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with id: String, completion: @escaping ((Bool) -> Void )) {
        database.child("users/\(id)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// inserts new user to database
    public func insertUser(with profile: UserProfileResponse, completion: @escaping ((Bool) ->Void)) {
        
        // set user's top tracks, artists & genres
        // top artist
        APICaller.shared.getTopArtists { [weak self] result in
            switch result {
            case .success(let topArtistsResponse):
                // convert to json
                guard let data = try? JSONEncoder().encode(topArtistsResponse), let topArtists = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(false)
                    return
                }
            
                    
                // top genres (based on genres of top artists)
                // for uniqueness

                APICaller.shared.getTopTracks { [weak self] result in
                    switch result {
                    case .success(let topTracksResponse):
                        // convert to json
                        guard let data = try? JSONEncoder().encode(topTracksResponse), let topTracks = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            completion(false)
                            return
                        }
                        
                        let topGenres = topArtistsResponse.items
                            .compactMap { $0.genres }.reduce([]) {return Set($0).union(Set($1))}
                            .map { $0.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression) }

                        
                        let topGenreUpdates = topGenres.reduce([String: Any]()) {
                            var dict = $0
                            dict["genres/\($1)"] = true
                            return dict
                        }
                        
                        let topArtistUpdates = topArtistsResponse.items.map { $0.name.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression) }.reduce([String: Any]()) {
                            var dict = $0
                            dict["artists/\($1)/\(profile.id)"] = true
                            return dict
                        }
                        
                        let topTrackUpdates = topTracksResponse.items.map { $0.name.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression) }.reduce([String: Any]()) {
                            var dict = $0
                            dict["tracks/\($1)/\(profile.id)"] = true
                            return dict
                        }
                        
                        print("IIII: ", topArtistUpdates)
                        print("IIII: ", topTrackUpdates)
                        

                        // create the user
                        print("creating new user")
                        let userUpdates: [String: Any] = [
                            "users/\(profile.id)" : [
                                "id": profile.id, //redundant but whatever
                                "name": profile.display_name,
                                "email": profile.email,
                                "profile_picture": profile.images.first?.url,
                                "top_artists": topArtists,
                                "top_tracks": topTracks,
                                "top_genres": Array(topGenres)
                            ]
                        ]
                        let allUpdates = userUpdates.merging(topTrackUpdates) { (_, new) in new }
                                                    .merging(topArtistUpdates) { (_, new) in new }
                                                    .merging(topGenreUpdates) { (_, new) in new }
                        
                        self?.database.updateChildValues(allUpdates) { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }

                    case .failure( _):
                        completion(false)
                    }
                }
       
             
            case .failure(_):
                completion(false)
            }
        }
    }
    
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
                                            
}



// MARK: - user related, getting user, user data and suggested users (users in the same room as the current user)
    
extension DatabaseManager {
    
    public func getUser(with id: String, completion: @escaping (Result<Message.ChatUserItem, Error>) -> Void) {
        
        database.child("users/\(id)").observeSingleEvent(of: .value) { snapshot in
            
            guard let user = snapshot.value as? [String: Any],
                  let name = user["name"] as? String,
                  let id = user["id"] as? String else {
                completion(.failure(Self.DatabaseError.failedToFetch))
                return
            }
 
            var topTracksResponse: TopTracksResponse?
            var topArtistsResponse: TopArtistsResponse?
            var topGenres: [String]?
            // revist this
            if let top_artists = user["top_artists"],
               let artistsJSON = try? JSONSerialization.data(withJSONObject: top_artists) {
               topArtistsResponse = try? JSONDecoder().decode(TopArtistsResponse.self, from: artistsJSON)
                
            }
            
            if let top_tracks = user["top_tracks"] {
                if JSONSerialization.isValidJSONObject(top_tracks) {
                    if let tracksJSON = try? JSONSerialization.data(withJSONObject: top_tracks) {
                        do {
                            topTracksResponse = try JSONDecoder().decode(TopTracksResponse.self, from: tracksJSON)
                        } catch {
                            print("ERROR:", error)
                        }
                    }
                }
            }
            
            topGenres = user["top_genres"] as? [String]
             var photoURL: URL?
             if let photoURLString = user["profile_picture"] as? String {
                 photoURL = URL(string: photoURLString)
             }
            
            completion(.success(.init(userName: name, avatarURL: photoURL, avatar: nil, id: id, topTracks: topTracksResponse, topArtists: topArtistsResponse, topGenres: topGenres)))
                
        }
    }


    public func getUsers(in room: String, completion: @escaping (Result<[Message.ChatUserItem], Error>) -> Void) {
        
        self.database.child("users").queryOrdered(byChild: "room").queryEqual(toValue: "\(room)").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            var users = [Message.ChatUserItem]()
            for case let userSnapshot as DataSnapshot in snapshot.children {
                if let user = userSnapshot.value as? [String: Any],
                   let name = user["name"] as? String,
                   let id = user["id"] as? String {

                    var topTracksResponse: TopTracksResponse?
                    var topArtistsResponse: TopArtistsResponse?
                    var topGenres: [String]?
                    // revist this
                    if let top_artists = user["top_artists"],
                       let artistsJSON = try? JSONSerialization.data(withJSONObject: top_artists) {
                       topArtistsResponse = try? JSONDecoder().decode(TopArtistsResponse.self, from: artistsJSON)
                        
                    }
                    
                    if let top_tracks = user["top_tracks"] {
                        if JSONSerialization.isValidJSONObject(top_tracks) {
                            if let tracksJSON = try? JSONSerialization.data(withJSONObject: top_tracks) {
                                do {
                                    topTracksResponse = try JSONDecoder().decode(TopTracksResponse.self, from: tracksJSON)
                                } catch {
                                    print("ERROR:", error)
                                }
                            }
                        }
                    }
                    
                    topGenres = user["top_genres"] as? [String]
                     var photoURL: URL?
                     if let photoURLString = user["profile_picture"] as? String {
                         photoURL = URL(string: photoURLString)
                     }
                    
                    users.append(.init(userName: name, avatarURL: photoURL, avatar: nil, id: id, topTracks: topTracksResponse, topArtists: topArtistsResponse, topGenres: topGenres))
                    
                } else {
                    // shouldn't happen
                    continue
                }
     
            }
            completion(.success(users))
        }
    }
    
    // test these
    public func getTopTracks(for id: String,  completion: @escaping ((Result<TopTracksResponse, Error>) ->Void)) {
        self.database.child("users/\(id)/top_tracks").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value, let data = try? JSONSerialization.data(withJSONObject: value), let result = try? JSONDecoder().decode(TopTracksResponse.self, from: data)  else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(result))
        })
        
    }
    
    public func getTopArtists(for id: String,  completion: @escaping ((Result<TopArtistsResponse, Error>) ->Void)) {
        self.database.child("users/\(id)/top_artists").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value, let data = try? JSONSerialization.data(withJSONObject: value), let result = try? JSONDecoder().decode(TopArtistsResponse.self, from: data)  else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(result))
        })
        
    }
}


//MARK: - Chat
extension DatabaseManager {
    public static let maxNumOfMessagesToFetch: UInt = 100
    
    public func acceptPendingInvitation(_ groupID: String, completion: @escaping ((Bool) -> Void)) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid,
              let currentUserName = AuthManager.shared.currentUser?.displayName,
              let currentUserPhotoURL = AuthManager.shared.currentUser?.photoURL else {
            completion(false)
            return
        }
        
        database.child("users/\(currentUserID)/pending_invitations/\(groupID)").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            
            
            let updates: [String: Any?] = [
                "users/\(currentUserID)/pending_invitations/\(groupID)": nil, // remove the invitation
                "users/\(currentUserID)/Groups/\(groupID)": true,
                "Group/\(groupID)/users/\(currentUserID)": ["id": currentUserID, "name": currentUserName, "photoURL": currentUserPhotoURL]
            ]
            // atomic write
            self?.database.updateChildValues(updates) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    public func declinePendingInvitation(_ groupID: String, completion: @escaping ((Bool) -> Void)) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            completion(false)
            return
        }
        
        database.child("users/\(currentUserID)/pending_invitations/\(groupID)").removeValue() { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
   
    public func createGroup(with users: [Message.ChatUserItem], name: String, completion: @escaping ((Bool) ->Void)) {
        guard let currentUserName = AuthManager.shared.currentUser?.displayName else {
            completion(false)
            return
        }
        
        guard let groupID = database.child("Group").childByAutoId().key else {
            completion(false)
            return
        }

        // i have the groupID now
        // child updates
        // let childUpdates = users.map { ["/users/\($0.id)/group_invites/" : "\(groupID)"]}
        var childUpdates = users.reduce([String: Any]()) {
            var dict = $0
            dict["users/\($1.id)/pending_invitations/\(groupID)"] = true
            return dict
        }
        
        childUpdates["Group/\(groupID)/admin"] = currentUserName
        childUpdates["Group/\(groupID)/name"] = name
        database.updateChildValues(childUpdates) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    
    public func leaveGroup(_ groupID: String, completion: @escaping ((Bool) ->Void)) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            completion(false)
            return
        }
        
        let updates: [String: Any?] = [
            "users/\(currentUserID)/Groups/\(groupID)": nil,
            "Group/\(groupID)/users/\(currentUserID)": nil
        ] 
        database.updateChildValues(updates) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // called initially which is what i want
    // return id of the group the user was added to
    public func observeUserAdditionToGroup(completion: @escaping (String) ->Void) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            // user signed out already or the object hasn't been initalized yet
            // if this fails the observer won't be added so it's good enough
            // no need to add error handling
            return
        }
        database.child("users/\(currentUserID)/Groups").observe(.childAdded) { snapshot in
            completion(snapshot.key)
        }
    }
    
    public func observeUserRemovalFromGroup(completion: @escaping ((String) ->Void)) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            // user signed out already or the object hasn't been initalized yet
            // if this fails the observer won't be added so it's good enough
            // no need to add error handling
            return
        }
        database.child("users/\(currentUserID)/Groups").observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
    
    public func getGroup(with id: String, completition: @escaping (Result<Group, Error>) -> Void) {
        database.child("Group/\(id)").observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let name = dict["name"] as? String,
                  let admin = dict["admin"] as? String else {
                
                completition(.failure(DatabaseError.failedToFetch))
                return
                
            }
            
            var usersInfo = [UserInfo]()
            
            if let usersInfoDict = dict["users"] as? [String: [String: String]] {
                for (id, userInfo) in usersInfoDict {
                    if let name = userInfo["name"],
                       let photoURL = userInfo["photoURL"] {
                        usersInfo.append(UserInfo(id: id, name: name, photoURL: photoURL))
                    }
                }
                
            }
            completition(.success(Group(id: id, name: name, admin: admin, users: usersInfo)))
        }
    }
    
    public func observePendingInvites(completion: @escaping ((Result<[String], Error>) ->Void)) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            completion(.failure(AuthManager.AuthError.failedToGetCurrentUser)) // user signed out already or the object hasn't been initalized yet
            return
        }
        database.child("users/\(currentUserID)/pending_invitations").observe(.value) { snapshot in
            guard let group = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(group.keys.map { $0 }))
        }
    }
    
    public func removeMessagesObserver(_ group: String) {
        database.child("conversations/\(group)").removeAllObservers()
    }
    
    // probably don't need error handling for this, if i can't remove the observer it's whatever
    // only have to do this once anyways
    public func removeGroupObserver() {
  
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            return
        }
        database.child("users/\(currentUserID)/Groups").removeAllObservers()
        
    }
    
    public func sendMessage(message: Message.ChatMessageItem, to group: String, completion: ((Bool) -> Void)? = nil) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid,
              let currentUserName = AuthManager.shared.currentUser?.displayName else {
                completion?(false)
                return
        }
        
        var messageContent = ""
        let dateString = DateFormatter.dateFormatter.string(from: message.date)
        switch message.messageKind {
        case .text(let content):
            messageContent = content

        /// An image message, from local(UIImage) or remote(URL).
        case .image( _):
            break
            
        /// An image message, from local(UIImage) or remote(URL).
        case .imageText(_, _):
            break
            
            
        /// A location message, pins given location & presents on MapKit.
        case .location( _):
            break
            
        /// A contact message, generally for sharing purpose.
        case .contact( _):
            break
            
        /// Multiple options, disable itself after selection.
        case .quickReply( _):
            break
            
        /// `CarouselItem` contains title, subtitle, image & button in a scrollable view
        case .carousel( _):
            break
            
        /// A video message, opens the given URL.
        case .video( _):
            break
            
        /// Loading indicator contained in chat bubble
        case.loading:
            break
        }
        
  
        let newMessageRef = self.database.child("conversations/\(group)").childByAutoId()
        guard let messageID = newMessageRef.key else {
            completion?(false)
            return
        }
        let newMessage: [String: Any] = [
            "id": messageID,
            "type": message.messageKind.description,
            "content": messageContent,
            "date": dateString,
            "sender_id": currentUserID,
            "sender_name": currentUserName,
            "sender_profile_pic_url":  AuthManager.shared.currentUser?.photoURL?.absoluteString,
            "is_read": false
        ]
        
        newMessageRef.setValue(newMessage, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        })
    }
    
   

    

    public func observeRoomChange(completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            completion(.failure(AuthManager.AuthError.failedToGetCurrentUser)) // user signed out already or the object hasn't been initalized yet
            return
        }

        database.child("users/\(currentUserID)/room").observe(.value, with: { snapshot in
            guard let room = snapshot.value as? String else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(room))
            
        }, withCancel: { error in
            completion(.failure(error))
        })
    }
    
    
    
    
    
    /// listens for newly added messages. At first, all messages are fetched at once, then it the event only triggers for new messages.
    public func listenForMessages(in room: String, completion: @escaping (Result<Message.ChatMessageItem, Error>) -> Void) {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            // user signed out already or the object hasn't been initalized yet
            completion(.failure(AuthManager.AuthError.failedToGetCurrentUser))
            return
        }
        database.child("conversations/\(room)").queryLimited(toLast: Self.maxNumOfMessagesToFetch).observe(.childAdded, with: { snapshot in
            // let enumerator = snapshot.children

            // print("sss", enumerator.allObjects.count)
            //  print(snapshot.value as? [String: Any])

            if let dictionary = snapshot.value as? [String: Any],
               let isRead = dictionary["is_read"] as? Bool,
               let messageID = dictionary["id"] as? String,
               let content = dictionary["content"] as? String,
               let senderID = dictionary["sender_id"] as? String,
               let senderName = dictionary["sender_name"] as? String,
               let type = dictionary["type"] as? String,
               let dateString = dictionary["date"] as? String,
               let date = DateFormatter.dateFormatter.date(from: dateString) {
                
                var kind: ChatMessageKind?
                // won't be supporting photo/video/audio
                // location seems useful
                if type == "location" {
                    //TODO: take care of this
                } else if type == "MessageKind.text(\(content))" {
                    kind = .text(content)
                }

   
                if let finalKind = kind {
                    var avatarURL: URL?
                    if let avatarURLString = dictionary["sender_profile_pic_url"] as? String {
                        avatarURL = URL(string: avatarURLString)
                    }
                    let sender = Message.ChatUserItem(userName: senderName, avatarURL: avatarURL, avatar: nil, id: senderID)
                    completion(.success(Message.ChatMessageItem(user: sender, messageKind: finalKind, isSender: senderID == currentUserID, date: date, id: messageID)))
                }
                
            }
            
            
        }, withCancel: { error in
            completion(.failure(error))
        })
    }
    
    

    public func removeRoomChangeObserver() {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            return
        }
        database.child("users/\(currentUserID)/room").removeAllObservers()
    }
    
}



