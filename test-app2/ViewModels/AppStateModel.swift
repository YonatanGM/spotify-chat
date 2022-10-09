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
import AVKit


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
    @Published var messages = [Message.ChatMessageItem]()
    @Published var currentRoom: String?
    
    
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
    
    
    
    private var cancellables = Set<AnyCancellable>()
    private var userObserverHandle: UInt?

    // Group
    @Published var groups = [String: Group]()

    
    init() {
        // check if spotify is installed
        // ... if I want to open appstore in case spotify is not installed
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            isSpotifyInstalled = true
        }

        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                self?.setup()
            }
        })
        .store(in: &cancellables)
        

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            AuthManager.shared.currentUser = user
            
            if user != nil {
                AuthManager.shared.refreshIfNeeded()
                self?.signInStatus = .signedIn
            } else {
                // remove observers here
                self?.signInStatus = .signedOut
            }
        }
    }
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }
        return WebView(url: url) { [weak self] didStartAuthFlow in
            DispatchQueue.main.async {
                if didStartAuthFlow {
                    self?.signInStatus = .signingIn
                }
            }
        }
    }
    
    func signOut() {
        AuthManager.shared.signOut()
        signInStatus = .signedOut
    }
    
}


//MARK: - Conversations

extension AppStateModel {
    
    public func setup() {
        if let currentUserID = AuthManager.shared.currentUser?.uid {
            DatabaseManager.shared.getUser(with: currentUserID) { [weak self] result in
                switch result {
                case .success(let user):
                    self?.currentUser = user
                case .failure(_):
                    print("couldn't get current user")
                }
            }
        }
      
        DatabaseManager.shared.managePresence()
        
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
                            DatabaseManager.shared.listenForMessages(in: group.id) { result in
                                switch result {
                                case .success(let message):
                                    
                                    self?.groups[groupID]?.messages.append(message)
                                    
                                case .failure(_):
                                    print("failed to get messages in group \(group.id)")
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
            // DatabaseManager.shared.removeObserver(with: "Group/\(groupID)")
        }
        

        
        DatabaseManager.shared.observeInviteAcceptance() { [weak self] result in
            switch result {
            case .success(let groupID):
                self?.groups[groupID]?.pending = false 
                DatabaseManager.shared.listenForMessages(in: groupID) { result in
                    switch result {
                    case .success(let message):
                        self?.groups[groupID]?.messages.append(message)
                        
                    case .failure(_):
                        print("failed to get messages in group \(groupID)")
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
                if let handle =  self?.userObserverHandle {
                    DatabaseManager.shared.removeObserver(with: handle)
                }
                self?.currentRoom = room
                self?.userObserverHandle = DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        // update the users
                        self?.suggestedUsers = users
                       
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
                        
                    case .failure(_):
                        print("failed to get users in new room \(room)")
                    }
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
        // setup the AVPlayer
        
        avPlayer.actionAtItemEnd = .pause
        avPlayer.addPeriodicTimeObserver(forInterval:
                                                CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                             queue: .main,
                                             using: { [weak self] time in
            // weird problem here, starts at 0 and jump to 0.1
            // print(time.seconds)
            self?.progress = time.seconds / 30
        })

        // add oberver to detect when the preview ends
        let itemDidPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }
        
        let itemFailedToPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }

        let itemPlaybackStalledObserved = NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: nil, queue: .main) { [weak self] _ in
            // seek to beginning
            self?.play = false
            self?.avPlayer.pause()
            self?.avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 30))

        }
        

        
    }
    
}

extension AppStateModel {
    
    func queryUsersByArtistOrTrackName(_ terms: [String], completion: @escaping ([Message.ChatUserItem]) -> Void) {
        // clear previous result
        
        // remove ongoing observers
        DatabaseManager.shared.removeObserver(with: "User")
        // cancel search if it takes too long
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            DatabaseManager.shared.removeObserver(with: "User")
        }
        DatabaseManager.shared.queryUsersByArtistOrTrackName(terms) { results in
            // self?.searchResults = results
            completion(results)
            
        }
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

//MARK: - Additional functions
