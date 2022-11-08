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
import SwiftyChat
import AVKit
import BetterSafariView


class AppStateModel: ObservableObject {
    
    enum SignInStatus {
        case signedIn
        case signingIn
        case notDetermined
        case signedOut
    }
    
    @Published private(set) var signInStatus: SignInStatus = .notDetermined
    
    // @Published private(set) var users = [Message.ChatUserItem]()
    @Published var suggestedUsers = [Message.ChatUserItem]()
    
    @Published var selectedTrackID: String?

   
    // AVPlayer related
    var avPlayer = AVPlayer(playerItem: nil)
    @Published var playingTrackID: String?
    @Published var progress = 0.0
    @Published var play = false
    
    // assume spotify is not installed
    @Published var isSpotifyInstalled = false
    
    @Published var scrollToBottom = false
    @Published var searchResults = [Message.ChatUserItem]()
    
    @Published var currentUser: Message.ChatUserItem?
    @Published var likedTracks = [String: Bool]()
    @Published var followedUsers = [String: Bool]()
    @Published var blockedUsers = [String]()
    
    @Published var showChat = false
    @Published var navigateToChat = false
    
    
    @Published var selectedGroup: String?
    
    private var cancellables = Set<AnyCancellable>()
 

    // Group
    @Published var groups = [String: Group]()
    
    @Published var finishedLoadingOfSuggestedUsers = false
    
    // AVPlayer observers
    var itemDidPlayToEndTimeObserver: NSObjectProtocol? = nil
    var itemFailedToPlayToEndTimeObserver: NSObjectProtocol? = nil
    var itemPlaybackStalledObserver: NSObjectProtocol? = nil
    var timeObserverToken: Any? = nil

    // var onlineStatusHandles = Set<UInt?>()

    
    init() {
        // check if spotify is installed
        // ... if I want to open appstore in case spotify is not installed
        /*
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            isSpotifyInstalled = true
        }
        */

        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                self?.setup()
            }
        })
        .store(in: &cancellables)
        

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            AuthManager.shared.currentUser = user
            
            if user != nil {
                // spotify token refresh
                AuthManager.shared.refreshIfNeeded()
                // check if user exists in the database
                if let id = user?.uid {
                    DatabaseManager.shared.userExists(with: id) { exists in
                        if exists {
                            self?.signInStatus = .signedIn
                        }
                    }
                }
            } else {
                self?.signInStatus = .signedOut
            }
        }
    }
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebAuthenticationSession {
        return WebAuthenticationSession(
            url: AuthManager.shared.signInUrl!,
            callbackURLScheme: "chat-for-spotify-login"
        ) { [weak self] callbackURL, error in
            
            // print(callbackURL, error)
            guard error == nil,
                  let url = callbackURL,
                  let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {
                      $0.name == "code" })?.value else {
                return
            }
            self?.signInStatus = .signingIn
            AuthManager.shared.handleAuthorizationCodeFlow(code: code) { [weak self] success in
                DispatchQueue.main.async {
                    completion(success)
                    self?.signInStatus = success ? .signedIn : .signedOut
                    // print("user logged in and inserted in database")
                }

            }
        }
        .prefersEphemeralWebBrowserSession(false)
    }
    
    func signOut() {
        cleanup()
        DatabaseManager.shared.removePresence()
        AuthManager.shared.signOut { _ in }
    }
    
}


//MARK: - Conversations

extension AppStateModel {
    
    public func setup() {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else { return }
        DatabaseManager.shared.getUser(with: currentUserID) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
            case .failure(_):
                print("couldn't get current user")
            }
        }
        
      
        DatabaseManager.shared.managePresence()
        
        DatabaseManager.shared.observeBlockedUsers { [weak self] ids in
            self?.blockedUsers = ids
            self?.suggestedUsers.removeAll { ids.contains($0.id) }
            if let groups = self?.groups {
                for (id, group) in groups {
                    self?.groups[id]?.messages = group.messages.filter { !ids.contains($0.user.id) }
                }
            }
        }

        
        DatabaseManager.shared.observeNewGroup() { [weak self] result in
            
            switch result {
            case .success(let (groupID, userHasJoined)):
                DatabaseManager.shared.getGroup(with: groupID) { [weak self] result in
                    switch result {
                    case .success(var group):
                        group.pending = !userHasJoined
                        // self?.groups.append(group)
                        self?.groups[groupID] = group
                        // self?.groups.insert(group, at: 0)
                        // observe change in group child nodes
                        
                        DatabaseManager.shared.observeChangesInGroup(with: groupID) { result in
                            switch result {
                            
                            case .success(let (key, snapshotValue)):
                                // update group name
                                // print(key, snapshotValue)
                                if key == "name" {
                                    if let name = snapshotValue as? String {
                                        self?.groups[groupID]?.name = name
                                    }
                                } else if key == "users" {
                                    // update group users (in case a user joins or leaves the group)
                                    var users = [UserInfo]()
                                    if let usersInfoDict = snapshotValue as? [String: [String: String]] {
                                        for (id, userInfo) in usersInfoDict {
                                            if let name = userInfo["name"] {
                                                users.append(UserInfo(id: id, name: name, photoURL: userInfo["photoURL"], genreDisplay: userInfo["top_genre_display"]))
                                            }
                                        }
                                        self?.groups[groupID]?.users = users
                                    }
                                }
                                
                            case .failure(_):
                                print("failed to get changes at child locations of group \(groupID)")
                            }
                        }
                        if userHasJoined {
                            DatabaseManager.shared.getLastSeen(in: group.id) { lastSeenID in
                                DatabaseManager.shared.getBlockedUsers { blockedUserIDs in
                                    DatabaseManager.shared.observeMessages(in: group.id) { result in
                                        switch result {
                                        case .success(let message):
                                            guard let ids = self?.blockedUsers, !ids.contains(message.user.id) || !blockedUserIDs.contains(message.user.id) else {
                                                if message.id > self?.groups[groupID]?.lastSeenMessageID ?? lastSeenID {
                                                    DatabaseManager.shared.setLastSeen(for: groupID, messageID: message.id)
                                                }
                                                return
                                            }
                                            self?.groups[groupID]?.messages.append(message)
                                        case .failure(_):
                                            print("failed to get messages in group \(group.id)")
                                        }
                                    }
                                }
                            }
                            
                            DatabaseManager.shared.observeMessageModeration(in: groupID) { [weak self] result in
                                switch result {
                                case .success(let moderatedMessage):
                                    // print(moderatedMessage)
                                    if let index = (self?.groups[groupID]?.messages.firstIndex { $0.id == moderatedMessage.id }) {
                                        self?.groups[groupID]?.messages[index] = moderatedMessage
                                    }
                                case .failure(_):
                                    print("failed to get moderated meesage in group \(group.id)")
                                }
                            }
                            
                            DatabaseManager.shared.observeUnseenMessages(in: group.id) { lastSeenMessageID in
                                self?.groups[groupID]?.lastSeenMessageID = lastSeenMessageID
                            } onChangeOfUnseenCount: { unseenCount in
                                self?.groups[groupID]?.unseenCount = unseenCount
                            }
                        }

                    case .failure(_):
                        print("failed to get group with id \(groupID)")
                    }
                }
            case .failure(_):
                print("failed to get new group")
            }
            
        }
        
        DatabaseManager.shared.observeGroupRemoval() { [weak self] groupID in
            // self?.groups.removeAll { $0.id == groupID }
            self?.groups[groupID] = nil
            // stop observing messages in the room, good!
            DatabaseManager.shared.removeObserver(with: "conversations/\(groupID)")
            DatabaseManager.shared.removeObserver(with: "conversations_ids/\(groupID)")
            DatabaseManager.shared.removeObserver(with: "Group/\(groupID)")
            if let currentUserID = AuthManager.shared.currentUser?.uid {
                DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/lastSeen/\(groupID)")
                // what is this?
                // DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/blocked")
            }
        }
        

        
        DatabaseManager.shared.observeInviteAcceptance() { [weak self] result in
            switch result {
            case .success(let groupID):
                guard let group = self?.groups[groupID] else { return }
                self?.groups[groupID]?.pending = false
                DatabaseManager.shared.getLastSeen(in: group.id) { lastSeenID in
                    DatabaseManager.shared.getBlockedUsers { blockedUserIDs in
                        DatabaseManager.shared.observeMessages(in: groupID) { result in
                            switch result {
                            case .success(let message):
                                guard let ids = self?.blockedUsers, !ids.contains(message.user.id) || !blockedUserIDs.contains(message.user.id) else {
                                    if message.id > self?.groups[groupID]?.lastSeenMessageID ?? lastSeenID {
                                        DatabaseManager.shared.setLastSeen(for: groupID, messageID: message.id)
                                    }
                                    return
                                }
                                self?.groups[groupID]?.messages.append(message)
                                
                            case .failure(_):
                                print("failed to get messages in group \(group.id)")
                            }
                        }
                    }
                }
                
                DatabaseManager.shared.observeMessageModeration(in: groupID) { [weak self] result in
                    switch result {
                    case .success(let moderatedMessage):
                        if let index = (self?.groups[groupID]?.messages.firstIndex { $0.id == moderatedMessage.id }) {
                            self?.groups[groupID]?.messages[index] = moderatedMessage
                        }
                    case .failure(_):
                        print("failed to get moderated meesage in group \(group.id)")
                    }
                }
                
                DatabaseManager.shared.observeUnseenMessages(in: groupID) { lastSeenMessageID in
                    self?.groups[groupID]?.lastSeenMessageID = lastSeenMessageID
                } onChangeOfUnseenCount: { unseenCount in
                    self?.groups[groupID]?.unseenCount = unseenCount
                }
                
            case .failure(_):
                print("error getting id of pending group invite")
            }
        }
        
        
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {
                
            case .success(let room):
  
                DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        // update the users
                        
                        self?.suggestedUsers = users.filter { $0.id != AuthManager.shared.currentUser?.uid }.sorted { $0.id > $1.id }
                        if let blockedUsers = self?.blockedUsers {
                            self?.suggestedUsers.removeAll { blockedUsers.contains($0.id) }
                        }
                       
                        if let currentUser = (users.first { $0.id == AuthManager.shared.currentUser?.uid }) {
                            self?.currentUser = currentUser
                        }
                        
                        APICaller.shared.checkIfCurrentUserFollowsUsers(with: users.map { $0.id }) { result in
                            switch result {
                            case .success(let followedUsers):
                                DispatchQueue.main.async {
                                    self?.followedUsers = followedUsers
                                }
                                
                            case .failure(let error):
                                print("failed to check if current user follows users with ids \(users.map { $0.id }.joined(separator: ",")): \(error.localizedDescription)")
                            }
                        }
                        
                        let trackIDs =  users.compactMap { $0.topTracks?.items.first?.id }
                        APICaller.shared.checkIfUserHasSavedTracks(with: trackIDs) { result in
                            switch result {
                            case .success(let likedTracks):
                                DispatchQueue.main.async {
                                    self?.likedTracks = likedTracks
                                }
                                
                            case .failure(let error):
                                print("failed to check if current user liked tracks with ids \(trackIDs.joined(separator: ",")): \(error.localizedDescription)")
                            }
                        }
                        
                        if self?.finishedLoadingOfSuggestedUsers == false {
                            self?.finishedLoadingOfSuggestedUsers = true
                        }
                        
                    case .failure(_):
                        print("failed to get users in new room \(room)")
                    }
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        DatabaseManager.shared.observeUserDeletion() { [weak self] id in
            self?.suggestedUsers.removeAll { $0.id == id }
            self?.searchResults.removeAll { $0.id == id }
        }
        
        
        // setup the AVPlayer
        
        avPlayer.actionAtItemEnd = .pause
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval:
                                                CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                             queue: .main,
                                             using: { [weak self] time in
            // weird problem here, starts at 0 and jump to 0.1
            // print(time.seconds)
            self?.progress = time.seconds / 30
        })
        


        // add obervers to detect when the preview ends, if it stalls, etc
        itemDidPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }
        
        itemFailedToPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }

        itemPlaybackStalledObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }
    }
    
    
}


//MARK: - Remove observers

extension AppStateModel {
    public func cleanup() {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else { return }
        // UserInfo

        DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/Groups")
        DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/lastSeen")
        DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/blocked")
    
        groups.forEach { key, _ in
            // Group
            DatabaseManager.shared.removeObserver(with: "Group/\(key)")
            // Conversations
            DatabaseManager.shared.removeObserver(with: "conversations/\(key)")
            // Conversation ids
            DatabaseManager.shared.removeObserver(with: "conversations_ids/\(key)")
            // last seen
            DatabaseManager.shared.removeObserver(with: "userInfo/\(currentUserID)/lastSeen/\(key)")
        }
        
        // presence
        DatabaseManager.shared.removeObserver(with: "status/\(currentUserID)")
        // room change
        DatabaseManager.shared.removeObserver(with: "users/\(currentUserID)/room")
        // user removal
        DatabaseManager.shared.removeObserver(with: "users")
        
        // online status
        // onlineStatusHandles.compactMap { $0 }.forEach {
        //     DatabaseManager.shared.removeObserver(with: $0)
        // }
        
        // remove AVPlayer observers
        NotificationCenter.default.removeObserver(itemDidPlayToEndTimeObserver)
        NotificationCenter.default.removeObserver(itemPlaybackStalledObserver)
        NotificationCenter.default.removeObserver(itemFailedToPlayToEndTimeObserver)
        avPlayer.removeTimeObserver(timeObserverToken)
        
        // reset vars
        currentUser = nil
        groups = [:]
        likedTracks = [:]
        followedUsers = [:]
        suggestedUsers = []
        blockedUsers = []
        searchResults =  []
        selectedTrackID = nil
        selectedGroup = nil
        finishedLoadingOfSuggestedUsers = false
        playingTrackID = nil
        progress = 0.0
        play = false
        
    }
}

//MARK: - AVPlayer
extension AppStateModel {
    
    public func handlePlayback(of track: Track) {
        
        if playingTrackID != track.id {
            if let urlString = track.preview_url,
               let url = URL(string: urlString) {
                let playerItem = AVPlayerItem(url: url)
                progress = 0.0
                playingTrackID = track.id
                avPlayer.pause()
                avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
                avPlayer.replaceCurrentItem(with: playerItem)
                // start playing
                play = true
                avPlayer.playImmediately(atRate: 1.0)
            }
        } else {
            play = !play
            if play {
                avPlayer.playImmediately(atRate: 1.0)
            } else {
                if avPlayer.timeControlStatus == .playing {
                    avPlayer.pause()
                }
            }
        }
        
    }
    
    public func handlePlackbackOnChangeOfScenePhase(to phase: ScenePhase) {
        if phase == .background {
            // pause the player if it's playing when app goes to background
            if play == true {
                avPlayer.pause()
            }
        } else if phase == .active {
            // continue playing if the player was paused
            if play == true {
                avPlayer.play()
            }
        }
        
    }
    
    public func removePlayer() {
        play = false
        progress = 0.0
        playingTrackID = nil
        avPlayer.pause()
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    
}
