//
//  UserCardViewGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

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
                            .frame(height: Double(UIScreen.main.bounds.width) / 6)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                                
                            }
                            .matchedGeometryEffect(id: "pic", in: animation)
                        
                    } else {
                        
                        Image(systemName: "Person.fill")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: Double(UIScreen.main.bounds.width) / 6)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation {
                                    addedUsers = addedUsers.filter { $0.id != user.id}
                                }
                                
                            }
                            .matchedGeometryEffect(id: "pic", in: animation)
                        
                    }
                    
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {

                HStack {
                    ForEach(model.usersInCurrentRoom.filter { !addedUsers.contains($0) }, id: \.id) { user in
                        UserCardGroupCreation(namespace: animation, user: user)
                           
  
                            .onTapGesture {
                     
                
                                    withAnimation {
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
