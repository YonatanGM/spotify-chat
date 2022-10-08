//
//  BubbleView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.10.22.
//

import SwiftUI
import SDWebImageSwiftUI


import SwiftUI

struct UserBubbles: View {
    let users: [UserInfo]
    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(zip(users, getCircles(num: users.count, in: geometry.frame(in: .local)))), id: \.0.id) { user, path in
                if let urlString = user.photoURL, let url = URL(string: urlString) {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(2)
                        .offset(x: path.boundingRect.origin.x, y: path.boundingRect.origin.y)
                        .frame(width: path.boundingRect.width, height: path.boundingRect.height)
                } else {
                    UserPicInitials(name: user.name)
                        .padding(2)
                        .offset(x: path.boundingRect.origin.x, y: path.boundingRect.origin.y)
                        .frame(width: path.boundingRect.width, height: path.boundingRect.height)
                }
            }
        }
        .frame(width: 60, height: 60)
    }
    
    private func getCircles(num: Int, in frame: CGRect) -> [Path] {
                
        let transform = CGAffineTransform(scaleX: frame.width, y: frame.height)
        
        switch num {
        case 1:
            return [Path(ellipseIn: frame)]
        case 2:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0.5, y: 29, width: 70.5, height: 70.5)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 54, y: 0, width: 46, height: 46)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
        
        case 3:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0.5, y: 18, width: 63.5, height: 63.5)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 57, y: 0, width: 43, height: 43)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 57, y: 57, width: 43, height: 43)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
            
        case 4:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 9, width: 55, height: 55)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 14, y: 67, width: 33, height: 33)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 49, y: 49, width: 51, height: 51)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 55, y: 0, width: 45, height: 45)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
            
        case 5:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 41, height: 41)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 59, y: 59, width: 41, height: 41)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 43, width: 57, height: 57)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 45, y: 18, width: 37, height: 37)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 75, y: 0, width: 25, height: 25)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
        case 6:
            let frames = [ UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 46, height: 46)).bounds,
                           UIBezierPath(ovalIn: CGRect(x: 59, y: 59, width: 41, height: 41)).bounds,
                           UIBezierPath(ovalIn: CGRect(x: 0, y: 48, width: 52, height: 52)).bounds,
                           UIBezierPath(ovalIn: CGRect(x: 46, y: 24, width: 35, height: 35)).bounds,
                           UIBezierPath(ovalIn: CGRect(x: 71, y: 0, width: 29, height: 29)).bounds,
                           UIBezierPath(ovalIn: CGRect(x: 46, y: 0, width: 21, height: 21)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
            
        case 7:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 42, height: 42)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 58, y: 59, width: 41, height: 41)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 44, width: 56, height: 56)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 47, y: 21, width: 35, height: 35)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 75, y: 0, width: 25, height: 25)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 47, y: 0, width: 21, height: 21)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 83, y: 42, width: 17, height: 17)).bounds]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
            
        case 8:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 56, y: 56, width: 44, height: 44)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 66, width: 33, height: 34)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 34, y: 78, width: 22, height: 22)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 26, y: 46, width: 30, height: 30)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 51, y: 19, width: 35, height: 35)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 46, width: 19, height: 19)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 48, y: 0, width: 17, height: 17)).bounds
            ]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
        case 9:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 56, y: 56, width: 44, height: 44)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 66, width: 33, height: 34)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 34, y: 78, width: 22, height: 22)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 26, y: 46, width: 30, height: 30)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 51, y: 19, width: 35, height: 35)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 46, width: 19, height: 19)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 48, y: 0, width: 17, height: 17)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 86, y: 42, width: 14, height: 14)).bounds
            ]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
          
        case 10:
            let frames = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 56, y: 56, width: 44, height: 44)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 48, y: 0, width: 21, height: 21)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 66, width: 33, height: 34)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 34, y: 78, width: 22, height: 22)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 73, y: 0, width: 27, height: 27)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 26, y: 46, width: 30, height: 30)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 48, y: 21, width: 35, height: 35)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 0, y: 46, width: 19, height: 19)).bounds,
                          UIBezierPath(ovalIn: CGRect(x: 83, y: 40, width: 17, height: 17)).bounds
            ]
            return frames.map { Path(ellipseIn: $0).applying(CGAffineTransform(scaleX: 0.01, y: 0.01)).applying(transform) }
            
        default:
            return []
            
        }
    }
}
