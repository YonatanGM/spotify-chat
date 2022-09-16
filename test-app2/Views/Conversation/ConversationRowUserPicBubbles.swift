//
//  ConversationRowUserPicBubbles.swift
//  test-app2
//
//  Created by Yonatan Mamo on 16.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationRowUserPicBubbles: View {
    
    let group: Group
    
    private func nRandomPoints(_ num: Int) -> [CGPoint] {
        return (0...num).map { _ in
            CGPoint(x: CGFloat(Double.random(in: 0...1)),
                    y: CGFloat(Double.random(in: 0...1)))
        }
    }
    
    var admin: UserInfo? {
        group.users.filter { $0.id == group.admin }.first
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(group.users.enumerated()), id: \.offset) { index, user in
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                            Text("")
                        }
                        Spacer()
                    }
                    .border(.yellow)
                    .overlay(
                        ZStack {
                            ForEach(nRandomPoints(index).prefix(9), id: \.x) { point in
                                if let urlString = user.photoURL,
                                   let url = URL(string: urlString) {
                                    AnimatedImage(url: url)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(width: 30)
                                        .scaleEffect(Double(2) / Double(index + 1))
                                        .position(x: point.x * geometry.frame(in: .local).width,
                                                  y: point.y * geometry.frame(in: .local).height)
                                        .opacity(index > 0 ? Double(1) / Double(index + 1) : 0)
                                    
                                }

                            }
                        },
                        alignment: .topLeading)
                    .overlay (
                        ZStack {
                            if index == 0 {
                                if let admin = admin {
                                    if let urlString = admin.photoURL,
                                       let url = URL(string: urlString) {
                                        AnimatedImage(url: url)
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                    } else {
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                            .overlay(
                                                Text(admin.name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                                                    .font(.title)
                                                    .fontWeight(.thin)
                                                    .foregroundColor(.white)
                                                , alignment: .center)
                                        
                                    }
                                }
                            }
                        }
                    )
                }
            }
        }
         .frame(height: 60)
         .background(Color.gray)
         .clipShape(Capsule())
        
    }
}
