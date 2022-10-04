//
//  AuthManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.04.22.
//

import Foundation
import Firebase
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    
    var currentUser: User? = nil

    
    private var refreshingToken = false
    struct Constants {
        // revisit this
        static let clientID = "0a1b68ee7fdf43f287d15f82d31af2a7"
        static let clientSecret = "d446b893026d4021998ce6b161933057"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://localhost:5001/testapp-79467/us-central1/redirect"
        // add the scope for liking tracks here
        static let scopes = "user-read-private%20user-top-read%20user-follow-modify%20user-follow-read%20user-library-read%20user-library-modify"
    }
    
    private init() {}
    
    var signInUrl: URL? {
        return URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE")
    }
    
    // don't need this, don't think it's accurate
    var isSignedIn: Bool {
        return accessToken != nil && Self.shared.currentUser != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let after: TimeInterval = 300 // after 5 minutes, revisit this
        return currentDate.addingTimeInterval(after) >= expirationDate
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get base64")
            completion(false)
            return
        }
        
        // headers
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            // print("status: ", response)
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                print("SUCCESS: \(result)")
                completion(true)
            } catch {
                print("ERROR: ", error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private var onRefreshBlocks = [((String) -> Void)]()
    
    /// Supplies valid token to be used with api calls 
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            // Refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
                
            }
        } else if let token = accessToken {
            completion(token)
            
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)? = nil) {
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
    
        guard let _ = self.refreshToken else {
            return 
        }
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken = true
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: self.refreshToken)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get base64")
            completion?(false)
            return
        }
        
        // headers
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            // print("status: ", response)
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                // print("Successfully refreshed token")
                self?.onRefreshBlocks.forEach { $0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                // print("SUCCESS: \(result)")
                completion?(true)
            } catch {
                print("ERROR: ", error.localizedDescription)
                completion?(false)
            }
        }

        task.resume()
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    
    public func signOut() {
        try? Auth.auth().signOut()
        UserDefaults.standard.setValue(nil, forKey: "access_token")
    }
}


//MARK: - Firebase auth
extension AuthManager {
    
    public enum AuthError: Error {
        case failedToGetFirebaseToken
        case failedToConvertFirebaseTokenJSONToString
        case failedToGetCurrentUser

    }
    
    public func getFirebaseCustomToken(for uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let projectID = FirebaseApp.app()?.options.projectID,
              let url = URL(string: "http://localhost:5001/\(projectID)/us-central1/token?uid=\(uid)") else {
            return
        }

        let request = URLRequest(url: url)
        // execute the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // completion(.failure(APIError.failedToGetData))
                completion(.failure(AuthError.failedToGetFirebaseToken))
                print("etto,", error?.localizedDescription)
                return
            }
            
            do {
                let result = try JSONDecoder().decode([String: String].self, from: data)
                print("tokkk, ", result["token"])
                completion(.success(result["token"]!))
                
            } catch {
                completion(.failure(AuthError.failedToConvertFirebaseTokenJSONToString))
            }
        }
        task.resume()
        
    }
    
    public func firebaseLogIn(completion: ((Result<UserProfileResponse, Error>) -> Void)?) {
         
        // do spotify login first, then firebase stuff
        // simply call the getUserProfile to get the uid.
        APICaller.shared.getUserProfile { result in
            
            switch result {
            case .success(let profile):
                // GET request to trigger a cloud function which gets a custom token from the uid of the spotify user
                // the uid will be a query parameter in the request
                // the response contains the access token in json format
                self.getFirebaseCustomToken(for: profile.id) { result in
                    switch result {
                    case .failure(let error):
                        completion?(.failure(error))
                        return
                        
                    case .success(let token):
                        Auth.auth().signIn(withCustomToken: token) { result, error in
                            guard let result = result, error == nil else {
                                print("auth signin error ", error!.localizedDescription )
                                completion?(.failure(error!))
                                return
                            }
                            // print("logged in user\n", result.user)
                            
                            // set user display name
                            let changeRequest = result.user.createProfileChangeRequest()
                            changeRequest.displayName = profile.display_name 
                            if let url = profile.images.first?.url {
                                changeRequest.photoURL = URL(string: url)
                            }
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    print("couldn't set user displayName/photoURL", error.localizedDescription)
                                }
                            }
                            // update email
                            if let email = profile.email {
                                result.user.updateEmail(to: email)
                            }
                            
                    
                            // UserDefaults.standard.set(profile.display_name, forKey: "display_name")
                            completion?(.success(profile))
                            return
                        }
                    }
                }
                    

                
            case .failure(let error):
                print("error", error.localizedDescription)
                completion?(.failure(APICaller.APIError.failedToGetData))
                return
            }
        }
    }
        
    public func handleAuthorizationCodeFlow(code: String, completion: @escaping (Bool) -> Void) {
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] spotifyLoginSuccess in
            guard spotifyLoginSuccess else {
                completion(false)
                return
            }
 
            AuthManager.shared.firebaseLogIn { result in
                switch result {
                case .failure(let error):
                    completion(false)
                    return
                    
                case .success(let profile):
                    DatabaseManager.shared.userExists(with: profile.id) { exists in
                        guard !exists else {
                            completion(true)
                            return
                        }
                        // insert new user
                        DatabaseManager.shared.insertUser(with: profile) { success in
                            guard success else {
                                completion(false)
                                // delete user
                                
                                // then sign out
                                self?.signOut()
                                return
                            }
                            completion(true)
                 
                        }
                    }
                }
            }
        }
    }
}
