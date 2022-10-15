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

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.suggestedUsers, id: \.id) { user in
                    UserCard(user: user)
                        .padding([.horizontal], 1)
                        .padding(.leading, user.id == model.suggestedUsers.first?.id ? 10 : 0)
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
