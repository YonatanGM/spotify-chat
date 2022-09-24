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

    
    var body: some View {
        
        ZStack {
//            GeometryReader { geometry in
//                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
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
                VStack(alignment: .leading, spacing: 0) {
                    Text(group.name)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.light)
                    Spacer()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 1) {
                            ForEach(Array(Set(group.users.compactMap { $0.genreDisplay }).sorted()), id: \.self ) { genre in
                                     GenresAnimatedIcon(genre: genre)
                            }
                        }
                        
                    }
                    .frame(height: 20)
                    .clipShape(Capsule())
                    

                }
                Spacer()
            }
            

        }

        .frame(height: 60)        
        
    }
}
