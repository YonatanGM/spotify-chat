//
//  ChatView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct GroupChat: View {
    let numOfPoints = 30
    @State var chatUserCirclePositions: [CGPoint] = []
    let chatUserCircleHeight: CGFloat = 40
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {

                ForEach(chatUserCirclePositions.indices, id: \.self) { index in
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                             .stroke(.blue, lineWidth: 1)
                        )
                        .position(chatUserCirclePositions[index])
                        .frame(height: chatUserCircleHeight)

                }

                Color.red.opacity(0.25)
                    .padding(chatUserCircleHeight)
                
            }
            .onAppear {
                chatUserCirclePositions = [CGPoint](repeating: CGPoint(x: geometry.frame(in: .local).minX,
                                                                       y: geometry.frame(in: .local).maxY), count: numOfPoints)
                let padding = chatUserCircleHeight / 2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let points = makePath(frame: geometry.frame(in: .local).inset(by: .init(top: padding, left: padding, bottom: padding, right: padding)))
                    
                    for i in 0..<numOfPoints {
                        withAnimation(.easeOut(duration: Double(i) / Double(numOfPoints))) {
                            chatUserCirclePositions[i] = points[i]
                        }
                    }
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

struct GroupChat_Previews: PreviewProvider {
    static var previews: some View {
        GroupChat()
    }
}
