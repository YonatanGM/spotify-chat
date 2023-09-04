//
//  UserBio.swift
//  test-app2
//
//  Created by Yonatan Mamo on 29.06.23.
//

import SwiftUI

struct UserBio: View {
    @EnvironmentObject var model: AppStateModel
    let bioText: String
    var isCurrentUser = false
    var body: some View {
        HStack {
            // Spacer()
            if isCurrentUser {
                if model.didUnlockPremium {
                    SparklesIconBio()
                } else {
                    SparklesIconPulsing(size: CGSize(width: 20, height: 20)) {
                        // allow creating bio for the first time
                        if bioText == "" {
                            Task {
                                await model.updateBio()
                            }
                        } else {
                            if model.didRequestProduct == false {
                                Task {
                                    do {
                                        try await model.purchase()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            HStack {
     
                Text(bioText.trimmingCharacters(in: .punctuationCharacters))
                    .font(.custom("ChristmasWishCalligraphy-Calligraphy", size: 45))
                    // .font(.custom("GreatVibes-Regular", size: 30))
                    .multilineTextAlignment(.center)
                    
                

            }
            .frame(width: 250)
            .foregroundColor(.white)
            .animation(.spring(), value: model.bioCompletions)
        }
    }
    
}

