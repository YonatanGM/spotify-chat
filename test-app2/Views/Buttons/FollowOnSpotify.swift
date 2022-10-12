//
//  followOnSpotify.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.10.22.
//

import SwiftUI

struct FollowOnSpotify: View {
    @State var isTapping: Bool = false
    var logoHeight = 25.0
    let isFollowing: Bool
    var completion: () -> Void
    
    var body: some View {
        Button(action: {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                // do something
                completion()
            }
        }, label: {
            if !isFollowing {
                HStack(spacing: 0) {

                    Text("Follow on")
                        .font(.headline)
                        // .fontWeight(.bold)
                        // .font(.system(size: 15, weight: .bold, design: .default))
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    spotifyWhiteLogo.applying(CGAffineTransform(scaleX: 3.33 * logoHeight, y: logoHeight))
//                    Image("Spotify_Logo_RGB_White")
//                        .resizable()
//                        .scaledToFit()
                        .frame(width: 3.33 * logoHeight, height: logoHeight)
                        // .border(.red)
                        .padding(.leading, logoHeight / 2)
       
                }
            } else {
                HStack(spacing: 0) {
 
                    Text("Following")
                        .font(.headline)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                        // .fontWeight(.bold)
                        // .font(.system(size: 12, weight: .bold, design: .default))
                   
                    spotifyWhiteIcon.applying(CGAffineTransform(scaleX: logoHeight, y: logoHeight))
//                    Image("Spotify_Icon_RGB_White-1")
//                        .resizable()
//                        .scaledToFit()
                        .frame(width: logoHeight, height: logoHeight)
//                        .border(.red)
                        .padding(.leading, logoHeight / 2)
   
                }
            }
           
        })
         .padding(logoHeight / 2)
        .foregroundColor(.white)
        .background(
            Color.backdrop
        )
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .shadow(radius: 5)
    }
}

extension FollowOnSpotify {
    
    var spotifyWhiteLogo: Path {
        //// Color Declarations
        let fillColor2 = UIColor(red: 1.000, green: 0.999, blue: 0.996, alpha: 1.000)

        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 133.53, y: 74.48))
        bezierPath.addCurve(to: CGPoint(x: 36.24, y: 64.79), controlPoint1: CGPoint(x: 106.54, y: 58.45), controlPoint2: CGPoint(x: 62.01, y: 56.97))
        bezierPath.addCurve(to: CGPoint(x: 26.48, y: 59.57), controlPoint1: CGPoint(x: 32.11, y: 66.05), controlPoint2: CGPoint(x: 27.73, y: 63.71))
        bezierPath.addCurve(to: CGPoint(x: 31.7, y: 49.8), controlPoint1: CGPoint(x: 25.22, y: 55.43), controlPoint2: CGPoint(x: 27.55, y: 51.06))
        bezierPath.addCurve(to: CGPoint(x: 141.53, y: 61.01), controlPoint1: CGPoint(x: 61.28, y: 40.82), controlPoint2: CGPoint(x: 110.45, y: 42.56))
        bezierPath.addCurve(to: CGPoint(x: 144.26, y: 71.74), controlPoint1: CGPoint(x: 145.25, y: 63.22), controlPoint2: CGPoint(x: 146.47, y: 68.02))
        bezierPath.addCurve(to: CGPoint(x: 133.53, y: 74.48), controlPoint1: CGPoint(x: 142.06, y: 75.46), controlPoint2: CGPoint(x: 137.25, y: 76.69))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 132.65, y: 98.22))
        bezierPath.addCurve(to: CGPoint(x: 123.67, y: 100.37), controlPoint1: CGPoint(x: 130.75, y: 101.29), controlPoint2: CGPoint(x: 126.74, y: 102.26))
        bezierPath.addCurve(to: CGPoint(x: 40.22, y: 90.61), controlPoint1: CGPoint(x: 101.16, y: 86.54), controlPoint2: CGPoint(x: 66.85, y: 82.53))
        bezierPath.addCurve(to: CGPoint(x: 32.07, y: 86.26), controlPoint1: CGPoint(x: 36.77, y: 91.66), controlPoint2: CGPoint(x: 33.12, y: 89.71))
        bezierPath.addCurve(to: CGPoint(x: 36.43, y: 78.12), controlPoint1: CGPoint(x: 31.03, y: 82.81), controlPoint2: CGPoint(x: 32.98, y: 79.17))
        bezierPath.addCurve(to: CGPoint(x: 130.5, y: 89.25), controlPoint1: CGPoint(x: 66.84, y: 68.89), controlPoint2: CGPoint(x: 104.65, y: 73.36))
        bezierPath.addCurve(to: CGPoint(x: 132.65, y: 98.22), controlPoint1: CGPoint(x: 133.57, y: 91.14), controlPoint2: CGPoint(x: 134.53, y: 95.16))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 122.4, y: 121.02))
        bezierPath.addCurve(to: CGPoint(x: 115.23, y: 122.76), controlPoint1: CGPoint(x: 120.9, y: 123.49), controlPoint2: CGPoint(x: 117.68, y: 124.27))
        bezierPath.addCurve(to: CGPoint(x: 41.66, y: 114.69), controlPoint1: CGPoint(x: 95.56, y: 110.74), controlPoint2: CGPoint(x: 70.81, y: 108.03))
        bezierPath.addCurve(to: CGPoint(x: 35.41, y: 110.76), controlPoint1: CGPoint(x: 38.85, y: 115.33), controlPoint2: CGPoint(x: 36.05, y: 113.57))
        bezierPath.addCurve(to: CGPoint(x: 39.33, y: 104.51), controlPoint1: CGPoint(x: 34.76, y: 107.95), controlPoint2: CGPoint(x: 36.52, y: 105.15))
        bezierPath.addCurve(to: CGPoint(x: 120.67, y: 113.85), controlPoint1: CGPoint(x: 71.23, y: 97.22), controlPoint2: CGPoint(x: 98.6, y: 100.36))
        bezierPath.addCurve(to: CGPoint(x: 122.4, y: 121.02), controlPoint1: CGPoint(x: 123.13, y: 115.35), controlPoint2: CGPoint(x: 123.91, y: 118.56))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 84, y: 0.24))
        bezierPath.addCurve(to: CGPoint(x: 0.25, y: 83.98), controlPoint1: CGPoint(x: 37.75, y: 0.24), controlPoint2: CGPoint(x: 0.25, y: 37.73))
        bezierPath.addCurve(to: CGPoint(x: 84, y: 167.72), controlPoint1: CGPoint(x: 0.25, y: 130.23), controlPoint2: CGPoint(x: 37.75, y: 167.72))
        bezierPath.addCurve(to: CGPoint(x: 167.74, y: 83.98), controlPoint1: CGPoint(x: 130.25, y: 167.72), controlPoint2: CGPoint(x: 167.74, y: 130.23))
        bezierPath.addCurve(to: CGPoint(x: 84, y: 0.24), controlPoint1: CGPoint(x: 167.74, y: 37.73), controlPoint2: CGPoint(x: 130.25, y: 0.24))
        bezierPath.close()
 
        


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 228.09, y: 77.55))
        bezier2Path.addCurve(to: CGPoint(x: 211.06, y: 66.59), controlPoint1: CGPoint(x: 213.63, y: 74.1), controlPoint2: CGPoint(x: 211.06, y: 71.68))
        bezier2Path.addCurve(to: CGPoint(x: 222.31, y: 58.56), controlPoint1: CGPoint(x: 211.06, y: 61.79), controlPoint2: CGPoint(x: 215.58, y: 58.56))
        bezier2Path.addCurve(to: CGPoint(x: 242.07, y: 66.07), controlPoint1: CGPoint(x: 228.82, y: 58.56), controlPoint2: CGPoint(x: 235.29, y: 61.01))
        bezier2Path.addCurve(to: CGPoint(x: 242.78, y: 66.24), controlPoint1: CGPoint(x: 242.27, y: 66.22), controlPoint2: CGPoint(x: 242.53, y: 66.28))
        bezier2Path.addCurve(to: CGPoint(x: 243.41, y: 65.85), controlPoint1: CGPoint(x: 243.04, y: 66.2), controlPoint2: CGPoint(x: 243.26, y: 66.06))
        bezier2Path.addLine(to: CGPoint(x: 250.47, y: 55.9))
        bezier2Path.addCurve(to: CGPoint(x: 250.29, y: 54.61), controlPoint1: CGPoint(x: 250.76, y: 55.49), controlPoint2: CGPoint(x: 250.68, y: 54.93))
        bezier2Path.addCurve(to: CGPoint(x: 222.52, y: 44.99), controlPoint1: CGPoint(x: 242.22, y: 48.14), controlPoint2: CGPoint(x: 233.14, y: 44.99))
        bezier2Path.addCurve(to: CGPoint(x: 196, y: 67.77), controlPoint1: CGPoint(x: 206.91, y: 44.99), controlPoint2: CGPoint(x: 196, y: 54.36))
        bezier2Path.addCurve(to: CGPoint(x: 221.66, y: 91.16), controlPoint1: CGPoint(x: 196, y: 82.14), controlPoint2: CGPoint(x: 205.41, y: 87.23))
        bezier2Path.addCurve(to: CGPoint(x: 237.84, y: 101.79), controlPoint1: CGPoint(x: 235.5, y: 94.35), controlPoint2: CGPoint(x: 237.84, y: 97.02))
        bezier2Path.addCurve(to: CGPoint(x: 225.52, y: 110.37), controlPoint1: CGPoint(x: 237.84, y: 107.08), controlPoint2: CGPoint(x: 233.11, y: 110.37))
        bezier2Path.addCurve(to: CGPoint(x: 202.49, y: 100.86), controlPoint1: CGPoint(x: 217.08, y: 110.37), controlPoint2: CGPoint(x: 210.19, y: 107.53))
        bezier2Path.addCurve(to: CGPoint(x: 201.8, y: 100.63), controlPoint1: CGPoint(x: 202.3, y: 100.69), controlPoint2: CGPoint(x: 202.04, y: 100.62))
        bezier2Path.addCurve(to: CGPoint(x: 201.15, y: 100.97), controlPoint1: CGPoint(x: 201.54, y: 100.65), controlPoint2: CGPoint(x: 201.31, y: 100.77))
        bezier2Path.addLine(to: CGPoint(x: 193.23, y: 110.39))
        bezier2Path.addCurve(to: CGPoint(x: 193.32, y: 111.7), controlPoint1: CGPoint(x: 192.9, y: 110.78), controlPoint2: CGPoint(x: 192.94, y: 111.36))
        bezier2Path.addCurve(to: CGPoint(x: 225.19, y: 123.92), controlPoint1: CGPoint(x: 202.28, y: 119.7), controlPoint2: CGPoint(x: 213.3, y: 123.92))
        bezier2Path.addCurve(to: CGPoint(x: 252.89, y: 100.5), controlPoint1: CGPoint(x: 242.02, y: 123.92), controlPoint2: CGPoint(x: 252.89, y: 114.73))
        bezier2Path.addCurve(to: CGPoint(x: 228.09, y: 77.55), controlPoint1: CGPoint(x: 252.89, y: 88.48), controlPoint2: CGPoint(x: 245.71, y: 81.83))
        bezier2Path.close()

        


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 303.16, y: 93.66))
        bezier3Path.addCurve(to: CGPoint(x: 287.95, y: 110.9), controlPoint1: CGPoint(x: 303.16, y: 103.81), controlPoint2: CGPoint(x: 296.91, y: 110.9))
        bezier3Path.addCurve(to: CGPoint(x: 272.42, y: 93.66), controlPoint1: CGPoint(x: 279.1, y: 110.9), controlPoint2: CGPoint(x: 272.42, y: 103.49))
        bezier3Path.addCurve(to: CGPoint(x: 287.95, y: 76.42), controlPoint1: CGPoint(x: 272.42, y: 83.83), controlPoint2: CGPoint(x: 279.1, y: 76.42))
        bezier3Path.addCurve(to: CGPoint(x: 303.16, y: 93.66), controlPoint1: CGPoint(x: 296.76, y: 76.42), controlPoint2: CGPoint(x: 303.16, y: 83.67))
        bezier3Path.close()
        bezier3Path.move(to: CGPoint(x: 290.95, y: 63.29))
        bezier3Path.addCurve(to: CGPoint(x: 272.75, y: 72.04), controlPoint1: CGPoint(x: 283.66, y: 63.29), controlPoint2: CGPoint(x: 277.68, y: 66.16))
        bezier3Path.addLine(to: CGPoint(x: 272.75, y: 65.42))
        bezier3Path.addCurve(to: CGPoint(x: 271.8, y: 64.47), controlPoint1: CGPoint(x: 272.75, y: 64.9), controlPoint2: CGPoint(x: 272.32, y: 64.47))
        bezier3Path.addLine(to: CGPoint(x: 258.85, y: 64.47))
        bezier3Path.addCurve(to: CGPoint(x: 257.91, y: 65.42), controlPoint1: CGPoint(x: 258.33, y: 64.47), controlPoint2: CGPoint(x: 257.91, y: 64.9))
        bezier3Path.addLine(to: CGPoint(x: 257.91, y: 139.02))
        bezier3Path.addCurve(to: CGPoint(x: 258.85, y: 139.97), controlPoint1: CGPoint(x: 257.91, y: 139.54), controlPoint2: CGPoint(x: 258.33, y: 139.97))
        bezier3Path.addLine(to: CGPoint(x: 271.8, y: 139.97))
        bezier3Path.addCurve(to: CGPoint(x: 272.75, y: 139.02), controlPoint1: CGPoint(x: 272.32, y: 139.97), controlPoint2: CGPoint(x: 272.75, y: 139.54))
        bezier3Path.addLine(to: CGPoint(x: 272.75, y: 115.79))
        bezier3Path.addCurve(to: CGPoint(x: 290.95, y: 124.03), controlPoint1: CGPoint(x: 277.68, y: 121.32), controlPoint2: CGPoint(x: 283.66, y: 124.03))
        bezier3Path.addCurve(to: CGPoint(x: 318.22, y: 93.66), controlPoint1: CGPoint(x: 304.5, y: 124.03), controlPoint2: CGPoint(x: 318.22, y: 113.6))
        bezier3Path.addCurve(to: CGPoint(x: 290.95, y: 63.29), controlPoint1: CGPoint(x: 318.22, y: 73.72), controlPoint2: CGPoint(x: 304.5, y: 63.29))
        bezier3Path.close()



        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 353.37, y: 111))
        bezier4Path.addCurve(to: CGPoint(x: 337.1, y: 93.66), controlPoint1: CGPoint(x: 344.09, y: 111), controlPoint2: CGPoint(x: 337.1, y: 103.55))
        bezier4Path.addCurve(to: CGPoint(x: 353.16, y: 76.53), controlPoint1: CGPoint(x: 337.1, y: 83.73), controlPoint2: CGPoint(x: 343.85, y: 76.53))
        bezier4Path.addCurve(to: CGPoint(x: 369.54, y: 93.88), controlPoint1: CGPoint(x: 362.5, y: 76.53), controlPoint2: CGPoint(x: 369.54, y: 83.98))
        bezier4Path.addCurve(to: CGPoint(x: 353.37, y: 111), controlPoint1: CGPoint(x: 369.54, y: 103.8), controlPoint2: CGPoint(x: 362.74, y: 111))
        bezier4Path.close()
        bezier4Path.move(to: CGPoint(x: 353.37, y: 63.29))
        bezier4Path.addCurve(to: CGPoint(x: 322.25, y: 93.88), controlPoint1: CGPoint(x: 335.92, y: 63.29), controlPoint2: CGPoint(x: 322.25, y: 76.72))
        bezier4Path.addCurve(to: CGPoint(x: 353.16, y: 124.14), controlPoint1: CGPoint(x: 322.25, y: 110.85), controlPoint2: CGPoint(x: 335.83, y: 124.14))
        bezier4Path.addCurve(to: CGPoint(x: 384.38, y: 93.66), controlPoint1: CGPoint(x: 370.67, y: 124.14), controlPoint2: CGPoint(x: 384.38, y: 110.75))
        bezier4Path.addCurve(to: CGPoint(x: 353.37, y: 63.29), controlPoint1: CGPoint(x: 384.38, y: 76.63), controlPoint2: CGPoint(x: 370.76, y: 63.29))
        bezier4Path.close()



        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 421.64, y: 64.47))
        bezier5Path.addLine(to: CGPoint(x: 407.4, y: 64.47))
        bezier5Path.addLine(to: CGPoint(x: 407.4, y: 49.9))
        bezier5Path.addCurve(to: CGPoint(x: 406.45, y: 48.96), controlPoint1: CGPoint(x: 407.4, y: 49.38), controlPoint2: CGPoint(x: 406.98, y: 48.96))
        bezier5Path.addLine(to: CGPoint(x: 393.51, y: 48.96))
        bezier5Path.addCurve(to: CGPoint(x: 392.56, y: 49.9), controlPoint1: CGPoint(x: 392.98, y: 48.96), controlPoint2: CGPoint(x: 392.56, y: 49.38))
        bezier5Path.addLine(to: CGPoint(x: 392.56, y: 64.47))
        bezier5Path.addLine(to: CGPoint(x: 386.33, y: 64.47))
        bezier5Path.addCurve(to: CGPoint(x: 385.39, y: 65.42), controlPoint1: CGPoint(x: 385.81, y: 64.47), controlPoint2: CGPoint(x: 385.39, y: 64.9))
        bezier5Path.addLine(to: CGPoint(x: 385.39, y: 76.55))
        bezier5Path.addCurve(to: CGPoint(x: 386.33, y: 77.49), controlPoint1: CGPoint(x: 385.39, y: 77.07), controlPoint2: CGPoint(x: 385.81, y: 77.49))
        bezier5Path.addLine(to: CGPoint(x: 392.56, y: 77.49))
        bezier5Path.addLine(to: CGPoint(x: 392.56, y: 106.29))
        bezier5Path.addCurve(to: CGPoint(x: 409.77, y: 123.82), controlPoint1: CGPoint(x: 392.56, y: 117.92), controlPoint2: CGPoint(x: 398.35, y: 123.82))
        bezier5Path.addCurve(to: CGPoint(x: 421.9, y: 120.8), controlPoint1: CGPoint(x: 414.41, y: 123.82), controlPoint2: CGPoint(x: 418.27, y: 122.86))
        bezier5Path.addCurve(to: CGPoint(x: 422.38, y: 119.98), controlPoint1: CGPoint(x: 422.19, y: 120.64), controlPoint2: CGPoint(x: 422.38, y: 120.32))
        bezier5Path.addLine(to: CGPoint(x: 422.38, y: 109.38))
        bezier5Path.addCurve(to: CGPoint(x: 421.93, y: 108.58), controlPoint1: CGPoint(x: 422.38, y: 109.06), controlPoint2: CGPoint(x: 422.2, y: 108.75))
        bezier5Path.addCurve(to: CGPoint(x: 421, y: 108.53), controlPoint1: CGPoint(x: 421.64, y: 108.4), controlPoint2: CGPoint(x: 421.29, y: 108.39))
        bezier5Path.addCurve(to: CGPoint(x: 413.4, y: 110.37), controlPoint1: CGPoint(x: 418.51, y: 109.79), controlPoint2: CGPoint(x: 416.1, y: 110.37))
        bezier5Path.addCurve(to: CGPoint(x: 407.4, y: 104.26), controlPoint1: CGPoint(x: 409.25, y: 110.37), controlPoint2: CGPoint(x: 407.4, y: 108.48))
        bezier5Path.addLine(to: CGPoint(x: 407.4, y: 77.49))
        bezier5Path.addLine(to: CGPoint(x: 421.64, y: 77.49))
        bezier5Path.addCurve(to: CGPoint(x: 422.59, y: 76.55), controlPoint1: CGPoint(x: 422.17, y: 77.49), controlPoint2: CGPoint(x: 422.59, y: 77.07))
        bezier5Path.addLine(to: CGPoint(x: 422.59, y: 65.42))
        bezier5Path.addCurve(to: CGPoint(x: 421.64, y: 64.47), controlPoint1: CGPoint(x: 422.59, y: 64.9), controlPoint2: CGPoint(x: 422.17, y: 64.47))
        bezier5Path.close()



        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 471.28, y: 64.53))
        bezier6Path.addLine(to: CGPoint(x: 471.28, y: 62.74))
        bezier6Path.addCurve(to: CGPoint(x: 477.82, y: 55.13), controlPoint1: CGPoint(x: 471.28, y: 57.47), controlPoint2: CGPoint(x: 473.3, y: 55.13))
        bezier6Path.addCurve(to: CGPoint(x: 485.12, y: 56.47), controlPoint1: CGPoint(x: 480.52, y: 55.13), controlPoint2: CGPoint(x: 482.69, y: 55.66))
        bezier6Path.addCurve(to: CGPoint(x: 485.97, y: 56.34), controlPoint1: CGPoint(x: 485.42, y: 56.57), controlPoint2: CGPoint(x: 485.73, y: 56.52))
        bezier6Path.addCurve(to: CGPoint(x: 486.37, y: 55.57), controlPoint1: CGPoint(x: 486.22, y: 56.16), controlPoint2: CGPoint(x: 486.37, y: 55.88))
        bezier6Path.addLine(to: CGPoint(x: 486.37, y: 44.66))
        bezier6Path.addCurve(to: CGPoint(x: 485.7, y: 43.75), controlPoint1: CGPoint(x: 486.37, y: 44.25), controlPoint2: CGPoint(x: 486.1, y: 43.88))
        bezier6Path.addCurve(to: CGPoint(x: 474.94, y: 42.21), controlPoint1: CGPoint(x: 483.13, y: 42.99), controlPoint2: CGPoint(x: 479.85, y: 42.21))
        bezier6Path.addCurve(to: CGPoint(x: 456.66, y: 61.67), controlPoint1: CGPoint(x: 462.98, y: 42.21), controlPoint2: CGPoint(x: 456.66, y: 48.94))
        bezier6Path.addLine(to: CGPoint(x: 456.66, y: 64.41))
        bezier6Path.addLine(to: CGPoint(x: 450.44, y: 64.41))
        bezier6Path.addCurve(to: CGPoint(x: 449.49, y: 65.36), controlPoint1: CGPoint(x: 449.91, y: 64.41), controlPoint2: CGPoint(x: 449.49, y: 64.84))
        bezier6Path.addLine(to: CGPoint(x: 449.49, y: 76.55))
        bezier6Path.addCurve(to: CGPoint(x: 450.44, y: 77.49), controlPoint1: CGPoint(x: 449.49, y: 77.07), controlPoint2: CGPoint(x: 449.91, y: 77.49))
        bezier6Path.addLine(to: CGPoint(x: 456.66, y: 77.49))
        bezier6Path.addLine(to: CGPoint(x: 456.66, y: 121.9))
        bezier6Path.addCurve(to: CGPoint(x: 457.6, y: 122.85), controlPoint1: CGPoint(x: 456.66, y: 122.43), controlPoint2: CGPoint(x: 457.08, y: 122.85))
        bezier6Path.addLine(to: CGPoint(x: 470.55, y: 122.85))
        bezier6Path.addCurve(to: CGPoint(x: 471.5, y: 121.9), controlPoint1: CGPoint(x: 471.07, y: 122.85), controlPoint2: CGPoint(x: 471.5, y: 122.43))
        bezier6Path.addLine(to: CGPoint(x: 471.5, y: 77.49))
        bezier6Path.addLine(to: CGPoint(x: 483.58, y: 77.49))
        bezier6Path.addLine(to: CGPoint(x: 502.1, y: 121.89))
        bezier6Path.addCurve(to: CGPoint(x: 495.11, y: 127.49), controlPoint1: CGPoint(x: 500, y: 126.56), controlPoint2: CGPoint(x: 497.93, y: 127.49))
        bezier6Path.addCurve(to: CGPoint(x: 487.97, y: 125.46), controlPoint1: CGPoint(x: 492.83, y: 127.49), controlPoint2: CGPoint(x: 490.43, y: 126.8))
        bezier6Path.addCurve(to: CGPoint(x: 487.22, y: 125.39), controlPoint1: CGPoint(x: 487.74, y: 125.33), controlPoint2: CGPoint(x: 487.47, y: 125.31))
        bezier6Path.addCurve(to: CGPoint(x: 486.66, y: 125.9), controlPoint1: CGPoint(x: 486.97, y: 125.48), controlPoint2: CGPoint(x: 486.76, y: 125.66))
        bezier6Path.addLine(to: CGPoint(x: 482.27, y: 135.53))
        bezier6Path.addCurve(to: CGPoint(x: 482.68, y: 136.75), controlPoint1: CGPoint(x: 482.06, y: 135.98), controlPoint2: CGPoint(x: 482.24, y: 136.52))
        bezier6Path.addCurve(to: CGPoint(x: 496.5, y: 140.29), controlPoint1: CGPoint(x: 487.26, y: 139.23), controlPoint2: CGPoint(x: 491.39, y: 140.29))
        bezier6Path.addCurve(to: CGPoint(x: 516, y: 123.86), controlPoint1: CGPoint(x: 506.06, y: 140.29), controlPoint2: CGPoint(x: 511.35, y: 135.84))
        bezier6Path.addLine(to: CGPoint(x: 538.47, y: 65.82))
        bezier6Path.addCurve(to: CGPoint(x: 538.37, y: 64.94), controlPoint1: CGPoint(x: 538.58, y: 65.53), controlPoint2: CGPoint(x: 538.54, y: 65.2))
        bezier6Path.addCurve(to: CGPoint(x: 537.59, y: 64.53), controlPoint1: CGPoint(x: 538.19, y: 64.68), controlPoint2: CGPoint(x: 537.9, y: 64.53))
        bezier6Path.addLine(to: CGPoint(x: 524.11, y: 64.53))
        bezier6Path.addCurve(to: CGPoint(x: 523.21, y: 65.16), controlPoint1: CGPoint(x: 523.71, y: 64.53), controlPoint2: CGPoint(x: 523.34, y: 64.78))
        bezier6Path.addLine(to: CGPoint(x: 509.4, y: 104.6))
        bezier6Path.addLine(to: CGPoint(x: 494.28, y: 65.14))
        bezier6Path.addCurve(to: CGPoint(x: 493.4, y: 64.53), controlPoint1: CGPoint(x: 494.14, y: 64.77), controlPoint2: CGPoint(x: 493.79, y: 64.53))
        bezier6Path.addLine(to: CGPoint(x: 471.28, y: 64.53))
        bezier6Path.close()



        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 428.62, y: 64.45, width: 14.85, height: 58.4), cornerRadius: 1)



        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 426.8, y: 38.75, width: 18.6, height: 18.6))



        //// Bezier 7 Drawing
        let bezier7Path = UIBezierPath()
        bezier7Path.move(to: CGPoint(x: 550.05, y: 70.09))
        bezier7Path.addLine(to: CGPoint(x: 547.68, y: 70.09))
        bezier7Path.addLine(to: CGPoint(x: 547.68, y: 73.11))
        bezier7Path.addLine(to: CGPoint(x: 550.05, y: 73.11))
        bezier7Path.addCurve(to: CGPoint(x: 551.94, y: 71.6), controlPoint1: CGPoint(x: 551.23, y: 73.11), controlPoint2: CGPoint(x: 551.94, y: 72.53))
        bezier7Path.addCurve(to: CGPoint(x: 550.05, y: 70.09), controlPoint1: CGPoint(x: 551.94, y: 70.62), controlPoint2: CGPoint(x: 551.23, y: 70.09))
        bezier7Path.close()
        bezier7Path.move(to: CGPoint(x: 551.59, y: 74.4))
        bezier7Path.addLine(to: CGPoint(x: 554.16, y: 78.01))
        bezier7Path.addLine(to: CGPoint(x: 551.99, y: 78.01))
        bezier7Path.addLine(to: CGPoint(x: 549.67, y: 74.7))
        bezier7Path.addLine(to: CGPoint(x: 547.68, y: 74.7))
        bezier7Path.addLine(to: CGPoint(x: 547.68, y: 78.01))
        bezier7Path.addLine(to: CGPoint(x: 545.86, y: 78.01))
        bezier7Path.addLine(to: CGPoint(x: 545.86, y: 68.45))
        bezier7Path.addLine(to: CGPoint(x: 550.12, y: 68.45))
        bezier7Path.addCurve(to: CGPoint(x: 553.81, y: 71.5), controlPoint1: CGPoint(x: 552.34, y: 68.45), controlPoint2: CGPoint(x: 553.81, y: 69.58))
        bezier7Path.addCurve(to: CGPoint(x: 551.59, y: 74.4), controlPoint1: CGPoint(x: 553.81, y: 73.07), controlPoint2: CGPoint(x: 552.9, y: 74.02))
        bezier7Path.close()
        bezier7Path.move(to: CGPoint(x: 549.57, y: 65.27))
        bezier7Path.addCurve(to: CGPoint(x: 541.37, y: 73.52), controlPoint1: CGPoint(x: 544.9, y: 65.27), controlPoint2: CGPoint(x: 541.37, y: 68.98))
        bezier7Path.addCurve(to: CGPoint(x: 549.52, y: 81.72), controlPoint1: CGPoint(x: 541.37, y: 78.06), controlPoint2: CGPoint(x: 544.88, y: 81.72))
        bezier7Path.addCurve(to: CGPoint(x: 557.72, y: 73.47), controlPoint1: CGPoint(x: 554.19, y: 81.72), controlPoint2: CGPoint(x: 557.72, y: 78.01))
        bezier7Path.addCurve(to: CGPoint(x: 549.57, y: 65.27), controlPoint1: CGPoint(x: 557.72, y: 68.93), controlPoint2: CGPoint(x: 554.21, y: 65.27))
        bezier7Path.close()
        bezier7Path.move(to: CGPoint(x: 549.52, y: 82.63))
        bezier7Path.addCurve(to: CGPoint(x: 540.41, y: 73.52), controlPoint1: CGPoint(x: 544.39, y: 82.63), controlPoint2: CGPoint(x: 540.41, y: 78.52))
        bezier7Path.addCurve(to: CGPoint(x: 549.57, y: 64.36), controlPoint1: CGPoint(x: 540.41, y: 68.52), controlPoint2: CGPoint(x: 544.45, y: 64.36))
        bezier7Path.addCurve(to: CGPoint(x: 558.68, y: 73.47), controlPoint1: CGPoint(x: 554.69, y: 64.36), controlPoint2: CGPoint(x: 558.68, y: 68.47))
        bezier7Path.addCurve(to: CGPoint(x: 549.52, y: 82.63), controlPoint1: CGPoint(x: 558.68, y: 78.46), controlPoint2: CGPoint(x: 554.64, y: 82.63))
        bezier7Path.close()

        
        var path = Path()
        path.addPath(Path(bezierPath.cgPath))
        path.addPath(Path(bezier2Path.cgPath))
        path.addPath(Path(bezier3Path.cgPath))
        path.addPath(Path(bezier4Path.cgPath))
        path.addPath(Path(bezier5Path.cgPath))
        path.addPath(Path(bezier6Path.cgPath))
        path.addPath(Path(bezier7Path.cgPath))
        path.addPath(Path(rectanglePath.cgPath))
        path.addPath(Path(ovalPath.cgPath))
        return path.applying(CGAffineTransform(scaleX: 1 / 558.43, y: 1 / 167.49))
        

    }
    
    var spotifyWhiteIcon: Path {
        //// Color Declarations
        let fillColor2 = UIColor(red: 1.000, green: 0.999, blue: 0.996, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 133.28, y: 74.24))
        bezierPath.addCurve(to: CGPoint(x: 35.99, y: 64.56), controlPoint1: CGPoint(x: 106.29, y: 58.21), controlPoint2: CGPoint(x: 61.76, y: 56.73))
        bezierPath.addCurve(to: CGPoint(x: 26.22, y: 59.34), controlPoint1: CGPoint(x: 31.85, y: 65.81), controlPoint2: CGPoint(x: 27.48, y: 63.48))
        bezierPath.addCurve(to: CGPoint(x: 31.44, y: 49.57), controlPoint1: CGPoint(x: 24.97, y: 55.2), controlPoint2: CGPoint(x: 27.3, y: 50.82))
        bezierPath.addCurve(to: CGPoint(x: 141.28, y: 60.77), controlPoint1: CGPoint(x: 61.02, y: 40.59), controlPoint2: CGPoint(x: 110.2, y: 42.32))
        bezierPath.addCurve(to: CGPoint(x: 144.01, y: 71.5), controlPoint1: CGPoint(x: 145, y: 62.98), controlPoint2: CGPoint(x: 146.22, y: 67.78))
        bezierPath.addCurve(to: CGPoint(x: 133.28, y: 74.24), controlPoint1: CGPoint(x: 141.8, y: 75.22), controlPoint2: CGPoint(x: 136.99, y: 76.45))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 132.4, y: 97.98))
        bezierPath.addCurve(to: CGPoint(x: 123.42, y: 100.13), controlPoint1: CGPoint(x: 130.5, y: 101.06), controlPoint2: CGPoint(x: 126.48, y: 102.02))
        bezierPath.addCurve(to: CGPoint(x: 39.97, y: 90.37), controlPoint1: CGPoint(x: 100.91, y: 86.3), controlPoint2: CGPoint(x: 66.59, y: 82.29))
        bezierPath.addCurve(to: CGPoint(x: 31.82, y: 86.02), controlPoint1: CGPoint(x: 36.52, y: 91.42), controlPoint2: CGPoint(x: 32.87, y: 89.47))
        bezierPath.addCurve(to: CGPoint(x: 36.17, y: 77.88), controlPoint1: CGPoint(x: 30.78, y: 82.57), controlPoint2: CGPoint(x: 32.73, y: 78.93))
        bezierPath.addCurve(to: CGPoint(x: 130.25, y: 89.01), controlPoint1: CGPoint(x: 66.59, y: 68.65), controlPoint2: CGPoint(x: 104.4, y: 73.12))
        bezierPath.addCurve(to: CGPoint(x: 132.4, y: 97.98), controlPoint1: CGPoint(x: 133.32, y: 90.9), controlPoint2: CGPoint(x: 134.28, y: 94.92))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 122.15, y: 120.79))
        bezierPath.addCurve(to: CGPoint(x: 114.97, y: 122.52), controlPoint1: CGPoint(x: 120.64, y: 123.25), controlPoint2: CGPoint(x: 117.43, y: 124.03))
        bezierPath.addCurve(to: CGPoint(x: 41.41, y: 114.45), controlPoint1: CGPoint(x: 95.31, y: 110.5), controlPoint2: CGPoint(x: 70.56, y: 107.79))
        bezierPath.addCurve(to: CGPoint(x: 35.16, y: 110.52), controlPoint1: CGPoint(x: 38.6, y: 115.09), controlPoint2: CGPoint(x: 35.8, y: 113.33))
        bezierPath.addCurve(to: CGPoint(x: 39.08, y: 104.27), controlPoint1: CGPoint(x: 34.51, y: 107.72), controlPoint2: CGPoint(x: 36.27, y: 104.92))
        bezierPath.addCurve(to: CGPoint(x: 120.42, y: 113.61), controlPoint1: CGPoint(x: 70.98, y: 96.98), controlPoint2: CGPoint(x: 98.34, y: 100.12))
        bezierPath.addCurve(to: CGPoint(x: 122.15, y: 120.79), controlPoint1: CGPoint(x: 122.88, y: 115.11), controlPoint2: CGPoint(x: 123.65, y: 118.33))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 83.74, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 83.74), controlPoint1: CGPoint(x: 37.49, y: 0), controlPoint2: CGPoint(x: 0, y: 37.49))
        bezierPath.addCurve(to: CGPoint(x: 83.74, y: 167.49), controlPoint1: CGPoint(x: 0, y: 130), controlPoint2: CGPoint(x: 37.49, y: 167.49))
        bezierPath.addCurve(to: CGPoint(x: 167.49, y: 83.74), controlPoint1: CGPoint(x: 129.99, y: 167.49), controlPoint2: CGPoint(x: 167.49, y: 130))
        bezierPath.addCurve(to: CGPoint(x: 83.74, y: 0), controlPoint1: CGPoint(x: 167.49, y: 37.49), controlPoint2: CGPoint(x: 129.99, y: 0))
        bezierPath.close()

        
        var path = Path()
        path.addPath(Path(bezierPath.cgPath))
        
        return path.applying(CGAffineTransform(scaleX: 1 / 167.49, y: 1 / 167.49))
    }
}
