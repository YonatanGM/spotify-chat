//
//  Users-ViewModel.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.05.22.
//

import Foundation

extension Users {
    @MainActor class ViewModel: ObservableObject {
        
        @Published private(set) var users = [[String: String]]()
        init() {
            loadUsers()

            
        }
        
        private func loadUsers() {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    // remove current user
                    self?.users = usersCollection
                case.failure(let error):
                    print("failed to get users: \(error)")
                }
                
            })
        }
        
        
        private func loadMatchingUsers() {
            // match making algorithm
        }
    }
}
