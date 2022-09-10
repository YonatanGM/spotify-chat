//
//  ChatView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct GroupChat: View {
    let numOfPoints = 20
    @State var chatUserCirclePositions: [CGPoint] = []
    @State var scale = 0.0
    let chatUserCircleHeight: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {

                LinearGradient(colors: [
                    Color(.sRGB,
                          red: Double(18) / 255,
                          green: Double(18) / 255,
                          blue: Double(18) / 255,
                          opacity: 0.75),
                    Color(.sRGB,
                          red: Double(18) / 255,
                          green: Double(18) / 255,
                          blue: Double(18) / 255,
                          opacity: 1)
  
                ], startPoint: .top, endPoint: .bottom)

                ForEach(chatUserCirclePositions.indices, id: \.self) { index in
                    Image(systemName: "circle.fill")
                    
                        .resizable()
                        .scaleEffect(scale)
                        .scaledToFit()
                        .clipShape(Circle())
                        .animation(.easeInOut(duration: 0.4).speed((Double(
                            index + 1) / Double(numOfPoints)) + Double(0.1)))
                       // .position(chatUserCirclePositions[index])
                        .animation(.easeOut(duration: 0.4).speed((Double(index + 1) / Double(numOfPoints)) + Double(0.1)))
                        .frame(height: chatUserCircleHeight)
                        .foregroundColor(        Color(
                            red: .random(in: 0...1),
                            green: .random(in: 0...1),
                            blue: .random(in: 0...1)
                        ))
                    

                }

         
                    SwiftyChatView()
                
     
                  
                
                   //  .padding([.horizontal, .top], chatUserCircleHeight)
                    .shadow(radius: 5)
                
            }
 
            .onAppear {
                chatUserCirclePositions = [CGPoint](repeating: CGPoint(x: geometry.frame(in: .local).minX,
                                                                       y: geometry.frame(in: .local).maxY), count: numOfPoints)
                let padding = chatUserCircleHeight / 2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    let points = makePath(frame: geometry.frame(in: .local).inset(by: .init(top: padding, left: padding, bottom: padding, right: padding)))
                    chatUserCirclePositions = points
                    scale = 0.5

                }


            }
        }

    }
    
    private func makePath(frame: CGRect) -> [CGPoint] {
        var path = Path()
        path.move(to: CGPoint(x: frame.minX, y: frame.maxY))
        path.addLine(to: CGPoint(x: frame.minX , y: frame.minY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        var points: [CGPoint] = [CGPoint(x: frame.minX, y: frame.maxY)]
        points += Array(0..<numOfPoints).compactMap {
            path.trimmedPath(from: 0, to: CGFloat($0) / CGFloat(numOfPoints  - 1)).currentPoint
        }
        return points
    }
}

extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct GroupChat_Previews: PreviewProvider {
    static var previews: some View {
        GroupChat()
    }
}
