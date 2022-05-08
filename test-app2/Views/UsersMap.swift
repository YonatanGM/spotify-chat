//
//  UsersList.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.05.22.
//

import SwiftUI

struct UsersMap: View {
    @EnvironmentObject var model: AppStateModel
    
 
    var body: some View {
        NavigationView {
            List {
                ForEach(model.users, id: \.id) { user in
                    NavigationLink(destination: {
                        Chat(otherUser: user)
                    }, label: {
                        Text(user.name)
                    })
                    
                }
            }
        }
        .onAppear {
            model.loadUsers()
        }
        
    }
}

struct UsersMap_Previews: PreviewProvider {
    static var previews: some View {
        UsersMap()
    }
}
