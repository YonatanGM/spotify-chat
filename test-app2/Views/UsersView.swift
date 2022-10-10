//
//  UsersView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI


struct UsersView: View {
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        if let currentUserID =  AuthManager.shared.currentUser?.uid {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(model.suggestedUsers.filter { $0.id != currentUserID }, id: \.id) { user in
                        UserCard(user: user)
                            .padding([.horizontal], 1)
                    }
                }
            }
        }


    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
