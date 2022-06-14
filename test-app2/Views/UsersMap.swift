//
//  ContentView.swift
//  circle-packing-4
//
//  Created by Yonatan Mamo on 01.06.22.
//

import SwiftUI
import CoreGraphics
import Foundation
import UIKit
import SDWebImageSwiftUI
import SwiftyChat

struct UsersMap: View {
    @EnvironmentObject var model: AppStateModel
    @State var gridSize: CGSize?
    @State var isDragging = false

   
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                ForEach(model.chatUserDisplayCircles, id: \.id) { circle in

                    NavigationLink(destination: {
                        
                        Text("\(circle.center.y)")
                            .navigationTitle(circle.id.uuidString.prefix(5))
                  
                
                    }, label: {
                        if let avatarURL = circle.user?.avatarURL {
                            AnimatedImage(url: avatarURL)
                               .resizable()
                               .clipShape(Circle())
                               .overlay(
                                   Circle()
                                    .stroke(.clear, lineWidth: 1)
                               )

                        } else {
                            Image(systemName: "person")
                               .resizable()
                               .clipShape(Circle())
                               .overlay(
                                   Circle()
                                       .stroke(.blue, lineWidth: 1)
                                   )
                        }

                    })

                    .frame(width: circle.circleWidth * (circle.scaleFactor ?? 1),
                           height: circle.circleWidth * (circle.scaleFactor ?? 1) ,
                           alignment: .center)
                    .position(x: circle.diplayCenter.x * geometry.size.width,
                              y: circle.diplayCenter.y * geometry.size.width)
                    .animation(.easeIn)
            
                }
                // .border(.red)

                .onAppear {
                    // print("width", geometry.size)
                    gridSize = geometry.size

                }
            }

        }
        .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width - 30)
        .contentShape(Rectangle())

        // .padding()
        .highPriorityGesture(DragGesture()
        .onChanged { value in
            // print("onchange", value.translation)
            isDragging = true
            guard let containerSize = gridSize else { return }
            model.processDragChange(value, containerSize: containerSize)
        }
        .onEnded { value in
           //  print("onend", value.translation)
            isDragging = false
            guard let containerSize = gridSize else { return }
            model.processDragFinished(value, containerSize: containerSize)
        })

        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                model.recenter()
            }) {
            Image(systemName: "scope")
                .imageScale(.small)
                .padding(3)
            }
        }
    }
}

struct UsersMap_Previews: PreviewProvider {
    static var previews: some View {
        UsersMap()
    }
}

