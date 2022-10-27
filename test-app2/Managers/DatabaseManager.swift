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
import Promises

class DatabaseManager {
   
   
   static let shared = DatabaseManager()
   
   // private let database = Database.database().reference()
   
   private let database = Database.database(url: "https://testapp-79467-default-rtdb.europe-west1.firebasedatabase.app").reference()
   
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
            
            // user has no top artist, likely newly created account, user can't use app in this case
            // might wanna handle this in the ui as well
            guard !topArtistsResponse.items.isEmpty else {
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
                  
                  let topArtistIndexUpdates = topArtistsResponse.items.map { $0.name.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression) }.reduce([String: Any]()) {
                     var dict = $0
                     // dict["artists/\(profile.id)/\($1)"] = true
                     // dict["users/\(profile.id)/search/\($1)"] = true
                     dict["search/\($1)/\(profile.id)"] = true
                     return dict
                  }
                  
                  let topTrackIndexUpdates = topTracksResponse.items.map { $0.name.lowercased().replacingOccurrences(of: "[\\[\\].$#]", with: " ", options: .regularExpression) }.reduce([String: Any]()) {
                     var dict = $0
                     // dict["tracks/\(profile.id)/\($1)"] = true
                     // dict["users/\(profile.id)/search/\($1)"] = true
                     dict["search/\($1)/\(profile.id)"] = true
                     return dict
                  }
                  
                  let userUpdates: [String: Any] = [
                     "users/\(profile.id)/id": profile.id, //redundant but whatever
                     "users/\(profile.id)/name": profile.display_name ?? profile.email,
                     "users/\(profile.id)/email": profile.email,
                     "users/\(profile.id)/country": profile.country,
                     "users/\(profile.id)/filter_enabled": profile.explicit_content["filter_enabled"],
                     "users/\(profile.id)/profile_picture": profile.images.first?.url,
                     "users/\(profile.id)/top_artists": topArtists,
                     "users/\(profile.id)/top_tracks": topTracks,
                     "users/\(profile.id)/top_genres": Array(topGenres),
                     "users/\(profile.id)/top_genre_display": topArtistsResponse.items.first?.genres?.first
                    
                     
                  ]
                  
                  // update the genres and search index first
                  let updates = topGenreUpdates.merging(topArtistIndexUpdates) { (_, new) in new }
                     .merging(topTrackIndexUpdates) { (_, new) in new }
                  self?.database.updateChildValues(updates) {  error, _ in
                     guard error == nil else {
                        completion(false)
                        return
                     }
                     
                     // create the user
                     self?.database.updateChildValues(userUpdates) { error, _ in
                        guard error == nil else {
                           completion(false)
                           return
                        }
                        completion(true)
                     }
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
   
   /// refetch current user from spotify and updates its data in the database
   @available(*, renamed: "refreshUser()")
   public func refreshUser(completion: @escaping ((Bool) ->Void)) -> Void {
      APICaller.shared.getCurrentUserProfile { [weak self] result in
         switch result {
         case .success(let profile):
            // delete and reinsert the user
            self?.database.child("users/\(profile.id)").setValue(nil) { error, _ in
               guard error == nil else {
                  completion(false)
                  return
               }
               self?.insertUser(with: profile) { result in
                  completion(result)
               }
            }
         case .failure(_):
            completion(false)
            return
         }
      }
   }
   
   public func refreshUser() async -> Bool {
      return await withCheckedContinuation { continuation in
         refreshUser() { result in
            continuation.resume(returning: result)
         }
      }
   }
   
   
   public func insertUser(with profile: UserProfileResponse) async -> Bool {
      return await withCheckedContinuation { continuation in
         insertUser(with: profile) { result in
            continuation.resume(returning: result)
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
               let id = user["id"] as? String,
               let country = user["country"] as? String,
               let filterEnabled = user["filter_enabled"] as? Bool else {
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
         
         completion(.success(.init(id: id,
                                   userName: name,
                                   avatarURL: photoURL,
                                   avatar: nil,
                                   topTracks: topTracksResponse,
                                   topArtists: topArtistsResponse,
                                   topGenres: topGenres,
                                   country: country,
                                   filterEnabled: filterEnabled)))
         
      }
   }
   
   public func getUsers(in room: String, completion: @escaping (Result<[Message.ChatUserItem], Error>) -> Void) {
      
      self.database.child("users").queryOrdered(byChild: "room").queryEqual(toValue: "\(room)").observeSingleEvent(of: .value) { [weak self] snapshot in
         
         var users = [Message.ChatUserItem]()
         guard let usersDict = snapshot.value as? [String: [String: Any]] else {
            completion(.failure(DatabaseError.failedToFetch))
            return
         }
         
         for user in usersDict.values {
            if let name = user["name"] as? String,
               let id = user["id"] as? String,
               let country = user["country"] as? String,
               let filterEnabled = user["filter_enabled"] as? Bool {
               
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
               
               users.append(.init(id: id, userName: name, avatarURL: photoURL, avatar: nil, topTracks: topTracksResponse, topArtists: topArtistsResponse, topGenres: topGenres, country: country, filterEnabled: filterEnabled))
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
            let currentUserName = AuthManager.shared.currentUser?.displayName else {
         completion(false)
         return
      }
      database.child("users/\(currentUserID)/top_genre_display").observeSingleEvent(of: .value) { [weak self] topGenreSnapshot in
         self?.database.child("userInfo/\(currentUserID)/Groups/\(groupID)").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard (snapshot.value as? Bool) == false else {
               completion(false)
               return
            }
            
        
            let updates: [String: Any?] = [
               "userInfo/\(currentUserID)/Groups/\(groupID)": true,
               "userInfo/\(currentUserID)/lastSeen/\(groupID)": "-",
               "Group/\(groupID)/users/\(currentUserID)": ["id": currentUserID,
                                                           "name": currentUserName,
                                                           "photoURL": AuthManager.shared.currentUser?.photoURL?.absoluteString,
                                                           "top_genre_display": topGenreSnapshot.value as? String]
            ]

            self?.database.updateChildValues(updates) { error, _ in
               guard error == nil else {
                  completion(false)
                  return
               }
               completion(true)
            }
         }
         
      }

   }
   
   public func declinePendingInvitation(_ groupID: String, completion: @escaping ((Bool) -> Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(false)
         return
      }
      
      database.child("userInfo/\(currentUserID)/Groups/\(groupID)").removeValue() { error, _ in
         guard error == nil else {
            completion(false)
            return
         }
         completion(true)
      }
      
   }
   
   
   public func createGroup(with users: [Message.ChatUserItem], name: String, completion: @escaping ((Bool) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid,
            let currentUserName = AuthManager.shared.currentUser?.displayName else {
         completion(false)
         return
      }
      
      database.child("users/\(currentUserID)/top_genre_display").observeSingleEvent(of: .value) { [weak self] topGenreSnapshot in
         guard let groupID = self?.database.child("Group").childByAutoId().key else {
            completion(false)
            return
         }
         
         // i have the groupID now
         // child updates
         // let childUpdates = users.map { ["/users/\($0.id)/group_invites/" : "\(groupID)"]}
         var childUpdates = users.reduce([String: Any]()) {
            var dict = $0
            dict["userInfo/\($1.id)/Groups/\(groupID)"] = false
            dict["Group/\(groupID)/invitees/\($1.id)"] = true
            return dict
         }
         
         childUpdates["Group/\(groupID)/admin"] = currentUserID
         childUpdates["Group/\(groupID)/name"] = name
         childUpdates["Group/\(groupID)/users/\(currentUserID)"] =  ["id": currentUserID,
                                                                     "name": currentUserName,
                                                                     "photoURL":  AuthManager.shared.currentUser?.photoURL?.absoluteString,
                                                                     "top_genre_display": topGenreSnapshot.value as? String]
         childUpdates["userInfo/\(currentUserID)/Groups/\(groupID)"] = true
         childUpdates["userInfo/\(currentUserID)/lastSeen/\(groupID)"] = "-"
         self?.database.updateChildValues(childUpdates) { error, _ in
            guard error == nil else {
               completion(false)
               return
            }
            completion(true)
         }
         
      }
   }
   
   public func directMessage(user: Message.ChatUserItem, completion: @escaping ((Bool) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid,
            let currentUserName = AuthManager.shared.currentUser?.displayName else {
         completion(false)
         return
      }
      
      // check if conversation already exists with the recipient
      database.child("Group")
         .queryOrdered(byChild: "name")
         .queryEqual(toValue: "\(currentUserID),\(user.id)")
         .observeSingleEvent(of: .value) { [weak self] snapshot in
            guard !snapshot.exists() else {
               completion(false)
               return
            }
            self?.database.child("Group")
               .queryOrdered(byChild: "name")
               .queryEqual(toValue: "\(user.id),\(currentUserID)")
               .observeSingleEvent(of: .value) { [weak self] snapshot in
                  guard !snapshot.exists() else {
                     completion(false)
                     return
                  }
                  // create the group
                  self?.database.child("users/\(currentUserID)/top_genre_display").observeSingleEvent(of: .value) { [weak self] topGenreSnapshot in
                     guard let groupID = self?.database.child("Group").childByAutoId().key else {
                        completion(false)
                        return
                     }
                     
                     var childUpdates = [String: Any]()
                     childUpdates["userInfo/\(user.id)/Groups/\(groupID)"] = false
                     childUpdates["Group/\(groupID)/invitees/\(user.id)"] = true
                     childUpdates["Group/\(groupID)/admin"] = currentUserID
                     childUpdates["Group/\(groupID)/name"] = "\(currentUserID),\(user.id)"
                     childUpdates["Group/\(groupID)/users/\(currentUserID)"] =  ["id": currentUserID,
                                                                                 "name": currentUserName,
                                                                                 "photoURL":  AuthManager.shared.currentUser?.photoURL?.absoluteString,
                                                                                 "top_genre_display": topGenreSnapshot.value as? String]
                     
                     childUpdates["Group/\(groupID)/recipient"] = ["id": user.id,
                                                                   "name": user.userName,
                                                                   "photoURL":  user.avatarURL?.absoluteString]
                     
                     childUpdates["Group/\(groupID)/invitees/\(currentUserID)"] = true
                     childUpdates["userInfo/\(currentUserID)/Groups/\(groupID)"] = true
                     childUpdates["userInfo/\(currentUserID)/lastSeen/\(groupID)"] = "-"
                     self?.database.updateChildValues(childUpdates) { error, _ in
                        guard error == nil else {
                           completion(false)
                           return
                        }
                        completion(true)
                     }
                  }
               }
         }
   }
   
   public func leaveGroup(_ groupID: String, completion: @escaping ((Bool) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(false)
         return
      }
//      removeObserver(with: "Group/\(groupID)")
//      removeObserver(with: "conversations/\(groupID)")
      let updates: [String: Any?] = [
         "userInfo/\(currentUserID)/Groups/\(groupID)": nil,
         "userInfo/\(currentUserID)/lastSeen/\(groupID)": nil,
         "Group/\(groupID)/users/\(currentUserID)": nil,
         "Group/\(groupID)/invitees/\(currentUserID)": nil
      ]
      database.updateChildValues(updates) { error, _ in
         guard error == nil else {
            completion(false)
            return
         }
         completion(true)
      }
   }
   
   public func deleteGroup(_ groupID: String, completion: @escaping (Bool) -> Void) {
      // delete the group, conversations, and remove group from users
      // pending groups ?
      // query the users
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(false)
         return
      }
//      removeObserver(with: "conversations/\(groupID)")
//      removeObserver(with: "Group/\(groupID)")
    
      var updates = [String: Any?]()
      // updates["Group/\(group.id)"] = nil
      updates.updateValue(nil, forKey: "userInfo/\(currentUserID)/Groups/\(groupID)")
      updates.updateValue(nil, forKey: "userInfo/\(currentUserID)/lastSeen/\(groupID)")
      updates.updateValue(nil, forKey: "Group/\(groupID)")
      // remove conversations
      // updates["conversations/\(group.id)"] = nil
      updates.updateValue(nil, forKey: "conversations/\(groupID)")
      updates.updateValue(nil, forKey: "conversations_ids/\(groupID)")
      database.child("Group/\(groupID)/invitees").observeSingleEvent(of: .value) { [weak self] snapshot in
         if let invitees = snapshot.value as? [String: Any] {
           
            for id in invitees.keys {
               // print(id)
               updates.updateValue(nil, forKey: "userInfo/\(id)/Groups/\(groupID)")
               updates.updateValue(nil, forKey: "userInfo/\(id)/lastSeen/\(groupID)")
            }
         }
         // print(updates)
         self?.database.updateChildValues(updates) { error, _ in
            guard error == nil else {
               completion(false)
               return
            }
            completion(true)
         }
         
      }

   }
   
   public func observeGroupRemoval(completion: @escaping ((String) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         // user signed out already or the object hasn't been initalized yet
         // if this fails the observer won't be added so it's good enough
         // no need to add error handling
         return
      }
      database.child("userInfo/\(currentUserID)/Groups").observe(.childRemoved) { snapshot in
         completion(snapshot.key)
       }
   }
   
   public func observeChangesInGroup(with id: String, completition: @escaping (Result<(String, Any?), Error>) -> Void) {
      database.child("Group/\(id)").observe(.childChanged) { snapshot in
         
         completition(.success((snapshot.key, snapshot.value)))
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
               if let name = userInfo["name"] {
                  usersInfo.append(UserInfo(id: id,
                                            name: name,
                                            photoURL: userInfo["photoURL"],
                                            genreDisplay: userInfo["top_genre_display"]))
               }
            }
         }
         var recipient: UserInfo?
         if let recipientDict = dict["recipient"] as? [String: String] {
            if let id = recipientDict["id"],
               let name = recipientDict["name"] {
               recipient = .init(id: id, name: name, photoURL: recipientDict["photoURL"], genreDisplay: nil)
            }
         }
         completition(.success(Group(id: id, name: name, admin: admin, users: usersInfo, recipient: recipient)))
      }
   }
   
   public func observeNewGroup(completion: @escaping ((Result<(String, Bool), Error>) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(.failure(AuthManager.AuthError.failedToGetCurrentUser))
         return
      }
      database.child("userInfo/\(currentUserID)/Groups").observe(.childAdded) { snapshot in
         guard let userHasJoined = snapshot.value as? Bool else {
            completion(.failure(DatabaseError.failedToFetch))
            return
         }
         completion(.success((snapshot.key, userHasJoined)))
      }
   }
   
   
   
   public func observeInviteAcceptance(completion: @escaping ((Result<String, Error>) ->Void)) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(.failure(AuthManager.AuthError.failedToGetCurrentUser)) // user signed out already or the object hasn't been initalized yet
         return
      }
      database.child("userInfo/\(currentUserID)/Groups").observe(.childChanged) { snapshot in
         guard let inviteAccepted = (snapshot.value as? Bool), inviteAccepted == true else {
            return
         }
         completion(.success(snapshot.key))
      }
   }
   
   
   public func removeMessagesObserver(_ group: String) {
      database.child("conversations/\(group)").removeAllObservers()
   }
   
   // probably don't need error handling for this, if i can't remove the observer it's whatever
   // only have to do this once anyways
   /*
   public func removeGroupObserver() {
      
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("users/\(currentUserID)/Groups").removeAllObservers()
      
   }
   */
   
   public func sendMessage(message: Message.ChatMessageItem, to group: String, completion: ((Bool) -> Void)? = nil) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid,
            let currentUserName = AuthManager.shared.currentUser?.displayName else {
         completion?(false)
         return
      }
      
      var messageContent = ""
      // let dateString = DateFormatter.dateFormatter.string(from: message.date)
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
      case .loading:
         break
      }
      
      var updates = [String: Any]()
      
      let newMessageRef = self.database.child("conversations/\(group)").childByAutoId()
      guard let messageID = newMessageRef.key else {
         completion?(false)
         return
      }
      
//      let a = ServerValue.timestamp()
      let newMessage: [String: Any] = [
         "id": messageID,
         "type": message.messageKind.description,
         "content": messageContent,
         "timestamp": ServerValue.timestamp(),
         "sender_id": currentUserID,
         "sender_name": currentUserName,
         "sender_profile_pic_url":  AuthManager.shared.currentUser?.photoURL?.absoluteString,
         "is_read": false
      ]
      
      updates["conversations_ids/\(group)/\(messageID)"] = true
      updates["conversations/\(group)/\(messageID)"] = newMessage
      database.updateChildValues(updates) { error, _ in
         guard error == nil else {
            completion?(false)
            return
         }
         completion?(true)
      }
   }
   
   
   public func observeRoomChange(completion: @escaping (Result<String, Error>) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         completion(.failure(AuthManager.AuthError.failedToGetCurrentUser))
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
   public func observeMessages(in group: String, completion: @escaping (Result<Message.ChatMessageItem, Error>) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         // user signed out or the object hasn't been initalized yet
         completion(.failure(AuthManager.AuthError.failedToGetCurrentUser))
         return
      }
      database.child("conversations/\(group)")
         .queryOrderedByKey()
         .queryLimited(toLast: Self.maxNumOfMessagesToFetch)
        
         .observe(.childAdded, with: { snapshot in
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
            let timeInterval = dictionary["timestamp"] as? TimeInterval {
            
            let date = Date(timeIntervalSince1970: timeInterval / 1000)
            var kind: ChatMessageKind?
            // won't be supporting photo/video/audio
            // location seems useful
            if type == "location" {
               //TODO: take care of this
            } else if type == "MessageKind.text(\(content))" {
               print(content)
               kind = .text(content)
            }
            
            
            if let finalKind = kind {
               var avatarURL: URL?
               if let avatarURLString = dictionary["sender_profile_pic_url"] as? String {
                  avatarURL = URL(string: avatarURLString)
               }
               let sender = Message.ChatUserItem(id: senderID, userName: senderName, avatarURL: avatarURL)
               completion(.success(Message.ChatMessageItem(user: sender, messageKind: finalKind, isSender: senderID == currentUserID, date: date, id: messageID)))
            }
            
         }
         
         
      }, withCancel: { error in
         completion(.failure(error))
      })
   }
   
  /// observers moderated messages (via firebase cloud function)
   public func observeMessageModeration(in group: String, completion: @escaping (Result<Message.ChatMessageItem, Error>) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         // user signed out or the object hasn't been initalized yet
         completion(.failure(AuthManager.AuthError.failedToGetCurrentUser))
         return
      }
      database.child("conversations/\(group)")
         .queryOrdered(byChild: "moderated")
         .queryEqual(toValue: true)
         .queryLimited(toLast: 1)
         .observe(.childAdded, with: { [weak self] snapshot in
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
            let timeInterval = dictionary["timestamp"] as? TimeInterval {
            
            let date = Date(timeIntervalSince1970: timeInterval / 1000)
            var kind: ChatMessageKind?
            // won't be supporting photo/video/audio
            // location seems useful
            if type == "location" {
               //TODO: take care of this
            } else if type == "MessageKind.text(\(content))" {
               print(content)
               kind = .text(content)
            }
            
            
            if let finalKind = kind {
               var avatarURL: URL?
               if let avatarURLString = dictionary["sender_profile_pic_url"] as? String {
                  avatarURL = URL(string: avatarURLString)
               }
               let sender = Message.ChatUserItem(id: senderID, userName: senderName, avatarURL: avatarURL)
               
               completion(.success(Message.ChatMessageItem(user: sender, messageKind: finalKind, isSender: senderID == currentUserID, date: date, id: messageID)))
               // moderation is completed at this point
               // remove the moderated flag
               // self?.database.child("conversations/\(group)/\(messageID)/moderated").setValue(nil)
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


//MARK: - Quering (get user by artist or track name)

extension DatabaseManager {
   
   public func queryUsersByArtistOrTrackName(_ searchTerms: [String], completion: @escaping ([String], [Message.ChatUserItem]) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else { return }
      guard !searchTerms.isEmpty else { return }

      let idPomises = searchTerms.reduce([Promise<[String]>]()) { result, term in
         print(term)
         return
         result +
            [Promise<[String]> { [weak self] fulfill, reject in
               self?.database.child("search/\(term)")
                  .queryOrderedByKey()
                  .queryLimited(toFirst: 20)
                  .observeSingleEvent(of: .value) { snapshot in
                     guard let ids = (snapshot.value as? [String: Bool])?.keys else {
                        fulfill([])
                        return
                     }
                     fulfill(Array(ids))
                  }
            }
         ]
      }
      
      all(idPomises).then { ids in
         let uniqueIDs = Set(ids.reduce([String]()) { $0 + $1 }).sorted().filter { $0 != currentUserID }
         print(uniqueIDs)
         let userPromises = uniqueIDs.reduce([Promise<Message.ChatUserItem?>]()) { result, id in
            result +
               [Promise<Message.ChatUserItem?> { [weak self] fulfill, reject in
                  self?.getUser(with: id) { result in
                     switch result {
                     case .success(let user):
                        fulfill(user)
                     case .failure(_):
                        fulfill(nil)
                     }
                  }
               }
            ]
         }
         
         all(userPromises).then { users in
            completion(searchTerms, users.compactMap { $0 })
         }
      }
   }
}


// MARK: - remove observer
extension DatabaseManager {
   
   public func removeObserver(with path: String) {
      database.child(path).removeAllObservers()
   }
   
   public func removeObserver(with handle: UInt) {
      database.removeObserver(withHandle: handle)
   }
}

//MARK: - Presence

extension DatabaseManager {
   public func managePresence() {
      // not doing error handling
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      
      database.child(".info/connected").observe(.value) { [weak self] snapshot in
          guard (snapshot.value as? Bool) == true else {
              return
          }
         self?.database.child("status/\(currentUserID)").onDisconnectSetValue(false) { error, _ in
            guard error == nil else {
               return
            }
            self?.database.child("status/\(currentUserID)").setValue(true)
         }
      }
   }
   
   public func checkOnlineStatus(for userID: String, completion: @escaping (Bool) -> Void) -> UInt {
      let handle = database.child("status/\(userID)").observe(.value) { snapshot in
         guard let isOnline = snapshot.value as? Bool else {
            completion(false)
            return
         }
         completion(isOnline)
      }
      return handle

   }
}


// MARK: - Unseen messages

extension DatabaseManager {
   
   public func observeUnseenMessages(in groupID: String, onChangeOfLastSeenMessage: @escaping (String) -> Void, onChangeOfUnseenCount: @escaping (UInt) -> Void) {
      
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("userInfo/\(currentUserID)/lastSeen/\(groupID)").observe(.value) { [weak self] snapshot in
         self?.database.child("conversations_ids/\(groupID)").removeAllObservers()
         guard let lastSeenID = snapshot.value as? String else {
            return
         }
         onChangeOfLastSeenMessage(lastSeenID)
         self?.database.child("conversations_ids/\(groupID)").queryOrderedByKey().queryStarting(afterValue: lastSeenID).observe(.value) { snapshot in
            onChangeOfUnseenCount(snapshot.childrenCount)
         }
      }
   }
   
   public func getLastSeen(in groupID: String, completion: @escaping (String) -> Void) {
      
      guard let currentUserID = AuthManager.shared.currentUser?.uid else { return }
      database.child("userInfo/\(currentUserID)/lastSeen/\(groupID)").observeSingleEvent(of: .value) { snapshot in
         guard let lastSeenID = snapshot.value as? String else {
            return
         }
         completion(lastSeenID)
      }
   }


   public func setLastSeen(for groupID: String, messageID: String) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("userInfo/\(currentUserID)/lastSeen/\(groupID)").setValue(messageID)
   }
}


// MARK: - Block users

extension DatabaseManager {
   
   public func blockUser(with id: String) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("userInfo/\(currentUserID)/blocked/\(id)").setValue(true)
      database.child("userInfo/\(id)/blocked/\(currentUserID)").setValue(true)
   }
   
   public func observeBlockedUsers(completion: @escaping ([String]) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("userInfo/\(currentUserID)/blocked").observe(.value) { snapshot in
         guard let ids = (snapshot.value as? [String: Bool])?.keys else {
            return
         }
         completion(Array(ids))
         
      }
   }
   
   public func getBlockedUsers(completion: @escaping ([String]) -> Void) {
      guard let currentUserID = AuthManager.shared.currentUser?.uid else {
         return
      }
      database.child("userInfo/\(currentUserID)/blocked").observeSingleEvent(of: .value) { snapshot in
         guard let ids = (snapshot.value as? [String: Bool])?.keys else {
            completion([])
            return
         }
         completion(Array(ids))
         
      }
   }

}
