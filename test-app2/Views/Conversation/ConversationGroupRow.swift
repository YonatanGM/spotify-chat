//
//  ConversationRowUserPicBubbles.swift
//  test-app2
//
//  Created by Yonatan Mamo on 16.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationGroupRow: View {
    @EnvironmentObject var model: AppStateModel
    let group: Group
    
    private func randomPoints(_ num: Int) -> [CGPoint] {
        var points = [CGPoint]()
        for i in 0..<num {
            points += (0...i).map { _ in
                CGPoint(x: CGFloat(Double.random(in: Double(i)...Double(i + 1))) / 5.0,
                        y: CGFloat(Double.random(in: 0...1)))
            }
        }
        return points
    }
    
    @State var points = [CGPoint]()
    @State var genres = [String]()
    var admin: UserInfo! {
        group.users.filter { $0.id == group.admin }.first
    }

    var lastMessage: String? {
        guard let message = group.messages.last?.messageKind else {
            return nil
        }
        switch message {
        case .text(let messageString):
            return messageString
        default:
            return nil
        }
    }
    
    var body: some View {
        
        ZStack {
//            GeometryReader { geometry in
//                ForEach(Array(randomPoints(2).enumerated()), id: \.offset) { index, point in
//                    if group.users.indices.contains(index) {
//                        if group.users[index].id != admin.id {
//                            if let urlString = group.users[index].photoURL,
//                               let url = URL(string: urlString) {
//                                AnimatedImage(url: url)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .clipShape(Circle())
//                                    .frame(width: 30)
//                                    .scaleEffect(1 - Double(point.x))
//                                    .position(x: point.x * geometry.frame(in: .local).width,
//                                              y: point.y * geometry.frame(in: .local).height)
//                                    .opacity(1 - Double(point.x))
//
//                            } else {
//                                Image(systemName: "circle.fill")
//                                    .resizable()
//                                    .foregroundColor(.gray)
//                                    .scaledToFit()
//                                    .clipShape(Circle())
//                                    .frame(width: 30)
//                                    .scaleEffect(1 - Double(point.x))
//                                    .position(x: point.x * geometry.frame(in: .local).width,
//                                              y: point.y * geometry.frame(in: .local).height)
//                                    .opacity(1 - Double(point.x))
//                                    .overlay(
//                                        Text(group.users[index].name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
//                                            .font(.title)
//                                            .fontWeight(.thin)
//                                            .foregroundColor(.white)
//                                        , alignment: .center)
//
//                                    .opacity(0.75)
//                            }
//                        }
//
//                    } else {
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30)
//                            .scaleEffect(1 - Double(point.x))
//
//                            .position(x: point.x * geometry.frame(in: .local).width,
//                                      y: point.y * geometry.frame(in: .local).height)
//                            .opacity(1 - Double(point.x))
//                            .foregroundColor(.gray)
//
//                        // .opacity(0.0)
//                    }
//                }
//            }
//            .padding([.vertical], 15)
            HStack {
                
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
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .overlay(
                            Text(admin.name.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                                .font(.title)
                                .fontWeight(.light)
                                .foregroundColor(.white)
                            , alignment: .center)
                  
                    
                    
                }
                VStack(alignment: .leading, spacing: 2.5) {
                    Spacer()
                    VStack(alignment: .leading, spacing: -2.5) {
                        Text(group.name)
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        if let lastMessage = lastMessage, group.pending == false {
                            Text(lastMessage)
                                .italic()
                                .fontWeight(.light)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 7.5)
           
                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 1) {
                                ForEach(group.users.compactMap { $0.genreDisplay }.unique, id: \.self ) { genre in
                                    GenresAnimatedIcon(genre: genre, parentFrame: geometry.size)
                                }
                            }
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 15)


                    Spacer()

                    //.border(.green)
             
                }
                
//                .padding(.vertical)
                Spacer()
            }
            

        }

        .frame(height: 60)        
        
    }
}
