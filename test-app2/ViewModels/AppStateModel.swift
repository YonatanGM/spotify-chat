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
import StoreKit


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
    
    @Published var recommendedTracks = [Track]()
    
    
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

    // store related
    var updateListenerTask: Task<Void, Error>? = nil
    let productID = "premium.feature"
    @Published var didUnlockPremium = false
    
    init() {
        // check if spotify is installed
        // ... if I need to open appstore incase Spotify is not installed
        /*
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            isSpotifyInstalled = true
        }
        */
        
        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                self?.updateListenerTask = self?.listenForTransactions()
                self?.setup()
            }
        })
        .store(in: &cancellables)

        self.$suggestedUsers.sink(receiveValue: { [weak self] users in
            if users.count > 0 && self?.finishedLoadingOfSuggestedUsers == false {
                self?.finishedLoadingOfSuggestedUsers = true
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
    
    deinit {
        cleanup()
        updateListenerTask?.cancel()
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
                // fetch similar users from pinecone DB
                self?.fetchSimilarUsers()
                
                // refresh track recommendations
                self?.getTrackRecommendations() { recommendations in
                    DispatchQueue.main.async {
                        if let recommendations = recommendations {
                            self?.recommendedTracks = recommendations
                        }
                    }
                }
                
                self?.fetchUserUpdates()
            case .failure(_):
                print("couldn't get current user")
            }
        }
        
      
        DatabaseManager.shared.managePresence()
        
        DatabaseManager.shared.observeBlockedUsers { [weak self] ids in
            self?.blockedUsers = ids
            self?.suggestedUsers.removeAll { ids.contains($0.id) }
            self?.searchResults.removeAll { ids.contains($0.id) }
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
        
        
        DatabaseManager.shared.observeUserDeletion() { [weak self] id in
            DispatchQueue.main.async {
                self?.suggestedUsers.removeAll { $0.id == id }
                self?.searchResults.removeAll { $0.id == id }
            }
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
        // current user
        DatabaseManager.shared.removeObserver(with: "users/\(currentUserID)")
        
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

//MARK: - Track recommendation
extension AppStateModel {
    // need a seed for the suffling
    public func getTrackRecommendations(seed: UInt64 = 0, completion: @escaping ([Track]?) -> Void) {
        guard let currentUser = self.currentUser,
              var topArtists = currentUser.topArtists?.items,
              // let topTracks = currentUser.topTracks?.items.shuffled(),
              var topRecentTracks = currentUser.topRecentTracks?.items else {
            completion([])
            return
        }

//        var generator = SeededGenerator(seed: seed)
//        topArtists.shuffle(using: &generator)
//        topRecentTracks.shuffle(using: &generator)
//
        
     
        let topArtistsSeed = topArtists.prefix(2).map({ $0.id })
        let topRecentTracksSeed = topRecentTracks.prefix(2).map({ $0.id })
        // let topTracksSeed = currentUser.topTracks?.items.shuffled().prefix(1).map({ $0.name })
        // let topGenresSeed = currentUser.topGenres?.shuffled().prefix(5).map({ $0 })
        let topGenresSeed = topArtists.prefix(1).compactMap { $0.genres }.reduce([]) { return Set($0).union(Set($1)) }.prefix(1).map { $0 }
        
       
        APICaller.shared.getRecommendations(seedArtists: topArtistsSeed,
                                            seedGenres: topGenresSeed,
                                            seedTracks: topRecentTracksSeed,
                                            limit: 10) { result in
            switch result {
            case .success(let recommendations):
                print(recommendations.map { $0.name })
                completion(recommendations)
                return
            case .failure(let error):
                completion(nil)
                print("Error getting track recommendations: ", error.localizedDescription)
            }
            
        }
        
    }
    
}


// update user on refresh
extension AppStateModel {
    
    public func fetchUserUpdates() {
        guard let id = self.currentUser?.id else {
            return
        }
        
        DatabaseManager.shared.observeUser(with: id) { [weak self] key, value in
            switch key {
            case "name":
                if let name = value as? String {
                    self?.currentUser?.userName = name
                }
            case "email":
                break
            case "country":
                if let country = value as? String {
                    self?.currentUser?.country = country
                }
            case "filter_enabled":
                if let filter_enabled = value as? Bool {
                    self?.currentUser?.filterEnabled = filter_enabled
                }
            case "profile_picture_stable":
                if let urlString = value as? String {
                    self?.currentUser?.avatarURL = URL(string: urlString)
                }
            case "top_artists":
                if let data = value,
                   let artistsJSON = try? JSONSerialization.data(withJSONObject: data),
                   let response = try? JSONDecoder().decode(ArtistsResponse.self, from: artistsJSON) {
                    self?.currentUser?.topArtists = response
                    
                }
            case "top_tracks":
                if let data = value,
                   let tracksJSON = try? JSONSerialization.data(withJSONObject: data),
                   let response = try? JSONDecoder().decode(TracksResponse.self, from: tracksJSON) {
                    self?.currentUser?.topTracks = response
                    
                }
            case "top_recent_tracks":
                if let data = value,
                   let tracksJSON = try? JSONSerialization.data(withJSONObject: data),
                   let response = try? JSONDecoder().decode(TracksResponse.self, from: tracksJSON) {
                    self?.currentUser?.topRecentTracks = response
                }
            case "top_genres":
                if let topGenres = value as? [String] {
                    self?.currentUser?.topGenres = topGenres
                }
                
            case "appAccountToken":
                // if it exists, it means the users has purchased the premium features
                if let product = value as? String {
                    self?.didUnlockPremium = true
                }
            default:
                return
                
            }
            
        }
    }
    
    public func fetchSimilarUsers() {
        guard let id = self.currentUser?.id else {
            return
        }
        PineconeManager.shared.queryEmbedding(id: id, topK: 15, namespace: "user-top-preferences") { [weak self] matches, error in
            guard let matches = matches, error == nil else {
                print(error?.localizedDescription)
                return
            }
            // remove current user's id
            DatabaseManager.shared.queryUsers(with: matches.filter({ $0 != id })) { users in
                DispatchQueue.main.async {
                    self?.suggestedUsers = users
                }
            }
        }
        
    }
    
}



// MARK: - Store, for premium features and stuff like that
extension AppStateModel {
    typealias Transaction = StoreKit.Transaction
    typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
    typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState
    
    public enum StoreError: Error {
        case failedVerification
    }

        
    // handle unfinished transcations close to app launch
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // by this point user has already signed in and the Auth object is probably created
            guard let id = AuthManager.shared.currentUser?.uid else {
                return
            }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    // if the transcation was made by the current user
                    // update the database to reflect that
                    // check this by comparing the app account token in the transcation result with the current user's
                    // read the app token id of the current if it exist from the database
                    await withCheckedContinuation { continuation in
                        DatabaseManager.shared.getAppAccountToken(for: id) { appAccountToken in
                            guard let currentUserAppAccountToken = appAccountToken,
                                  let transcationAppAccountToken = transaction.appAccountToken?.uuidString else {
                                continuation.resume()
                                return
                            }
                            
                            if currentUserAppAccountToken == transcationAppAccountToken {
                                // there was indeed an unfinished transcation that was successful
                                // And the transcation is related to the currently signed-in user
                                // the user's data most likely hasnt changed in the database
                                // so update that
                                DatabaseManager.shared.upgradeUser(with: id, appAccountToken: currentUserAppAccountToken)
                            }
                            continuation.resume()
                        }
                    }
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction verification failed")
                }
            }
        }
    }
    
    func purchase() async throws {
        
        guard let id = self.currentUser?.id else {
            throw DatabaseManager.DatabaseError.failedToFetch
        }
        // request the product
        let storeProducts = try await Product.products(for: ["premium.feature"])
        
        guard let product = storeProducts.first,
              product.type == .nonConsumable else {
            return
        }
        
        // Begin purchasing
        // need to create the app token, need it validate later if unfinised transcations belong to the current signed in user
        // by comparing the app token in the transcation with the current user's
        let result = try await product.purchase(options: [.appAccountToken(UUID())])
 
        switch result {
        case .success(let verification):
            //Check whether the transaction is verified
            let transaction = try checkVerified(verification)
            // The transaction is verified. Deliver content to the user.
            // update the databse
            if let uuid = transaction.appAccountToken?.uuidString {
                DatabaseManager.shared.upgradeUser(with: id, appAccountToken: uuid)
            }
            // finish the transaction.
            await transaction.finish()
      
        case .userCancelled, .pending:
            break
        default:
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
}
