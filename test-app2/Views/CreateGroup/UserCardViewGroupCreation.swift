//
//  UserCardViewGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI
import InitialsUI

struct UserCardViewGroupCreation: View {
    @EnvironmentObject var model: AppStateModel
    @State var selectedUserID: String? = nil
    @State var isTapping = false
    @State var addedUsers = [Message.ChatUserItem]()
    @Namespace private var animation
    var body: some View {
        
        VStack {
            
            HStack {
                ForEach(addedUsers, id: \.id) { user in
                    if let url = user.avatarURL {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: Double(UIScreen.main.bounds.width) / 10)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5))  {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                                
                            }
                            .matchedGeometryEffect(id: "pic", in: animation)
                        
                    } else {
                        
                        InitialsUI(initials: user.userName.components(separatedBy: " ").first ?? "", useDefaultForegroundColor: true, fontWeight: .light)
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: Double(UIScreen.main.bounds.width) / 10)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5))  {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                                
                            }
                            .matchedGeometryEffect(id: "picInitial", in: animation)
                        
                    }
                    
                }
            }
            .frame(height: 100)
            ScrollView(.horizontal, showsIndicators: false) {

                HStack {
                    ForEach(model.usersInCurrentRoom.filter { !addedUsers.contains($0) }, id: \.id) { user in
                        UserCardGroupCreation(user: user, namespace: animation)
                        
                            .onTapGesture {
                     
                
                                withAnimation(.spring(response: 0.5)) {
                                        addedUsers.append(user)
                                    }
                                   
                                
                                
                            }
                         



                    }
                }
            }
            .frame(height: Double(UIScreen.main.bounds.width) / 2)
            
        }

    }
}

struct UserCardViewGroupCreation_Previews: PreviewProvider {
    static var previews: some View {
        UserCardViewGroupCreation()
    }
}
