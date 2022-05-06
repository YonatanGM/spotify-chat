//
//  DatabaseManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 30.04.22.
//

import Foundation

import FirebaseDatabase

class DatabaseManager {
    
    
    static let shared = DatabaseManager()
    
    // private let database = Database.database().reference()
    private let database = Database.database(url: "http://localhost:9007?ns=testapp-79467").reference()
}


//MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with id: String, completion: @escaping ((Bool) -> Void )) {
        database.child(id).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    
    }
    
    /// inserts new user to database
    public func insertUser(with profile: UserProfile, completion: @escaping ((Bool) ->Void)) {
        database.child(profile.id).setValue([
            "country": profile.country,
            "name": profile.display_name,
            "email": profile.email ?? "",
            "profile_picture": profile.images.first?.url ?? ""
        ], withCompletionBlock: { [weak self] error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self?.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newElement = [
                        "name" : profile.display_name,
                        "email": profile.email ?? "",
                        "country": profile.country,
                        "profile_picture": profile.images.first?.url ?? ""
                    ]
                    usersCollection.append(newElement)
                    self?.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                } else {
                    let newCollection: [[String: String]] = [
                        ["name" : profile.display_name,
                        "email": profile.email ?? "",
                        "country": profile.country,
                        "profile_picture": profile.images.first?.url ?? ""]
                    ]
                    
                    self?.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("failed to write to database")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                
            })
            
        })
        
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
            
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
                                            
}
