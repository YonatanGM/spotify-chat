//
//  ConversationGroupRowPending.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationGroupRowPending: View {
    let group: Group
    @State var isTapping: Bool = false
    var body: some View {
        HStack {
            
            ZStack(alignment: .top) {
                ForEach(Array(group.users.prefix(3).enumerated()), id: \.offset) { index, user in
                    if let urlString = user.photoURL,
                       let url = URL(string: urlString) {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .offset(x: CGFloat(index))
                    } else {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .overlay(
                                Text(user.name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                                    .font(.title)
                                    .fontWeight(.thin)
                                    .foregroundColor(.white)
                                , alignment: .center)
                            .offset(x: CGFloat(index))
                    }
                }
            }
            .frame(width: 50)
            .border(.green)
            VStack(alignment: .leading, spacing: 0) {
                Text(group.name)
                    .font(.title)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 1) {
                        ForEach(group.genres_display, id: \.self) { genre in
                            GenresAnimatedIcon(genre: genre)
                        }
                    }
                }
                .frame(height: 25)
                .cornerRadius(10)
                .border(.blue)
            }
            
            // Join button
            VStack(alignment: .trailing) {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .foregroundColor(.gray)
                Spacer()
                HStack {
                    
                    Text("Accept")
                        .font(.headline)
                }
                .padding([.horizontal], 10)
                .padding([.vertical], 7.5)
                .foregroundColor(.white)
                .background(Color.backdrop)
                .clipShape(Capsule())
                .scaleEffect(isTapping ? 0.9 : 1)
                .brightness(isTapping ? 0.1 : 0)
                .onTapGesture {
                    // animation
                    withAnimation(.easeIn(duration: 0.1)) {
                        isTapping = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isTapping = false
                        }
                    }
                }
            }
            .padding([.trailing, .vertical], 5)
            
        }
        .foregroundColor(.white)
        .background(Color.backdrop)
        .cornerRadius(20)
        
    }
}

