//
//  UserBio.swift
//  test-app2
//
//  Created by Yonatan Mamo on 29.06.23.
//

import SwiftUI

struct UserBio: View {
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
    
        HStack(spacing: 0) {
  
            if !model.bioCompletions.isEmpty {
                ForEach(model.bioCompletions, id: \.self) { partialBio in
                    Text(partialBio)
                }
            } else if let bio = model.currentUser?.bio {
                Text(bio)
            }
        }
        .foregroundColor(.white)
        .animation(.spring(), value: model.bioCompletions)
        
        
    }
}


