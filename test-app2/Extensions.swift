//
//  Extensions.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.06.22.
//

import Foundation
import SwiftyChat
import SwiftUI

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}


extension Color {
    static let chatBlue = Color(#colorLiteral(red: 0.1405690908, green: 0.1412397623, blue: 0.25395751, alpha: 1))
    static let chatSpotifyColor = Color(#colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 0.5))
    static let backdrop = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05))
    static let chatGray = Color(#colorLiteral(red: 0.7861273885, green: 0.7897668481, blue: 0.7986581922, alpha: 1))
}

let futuraFont = Font.custom("Futura", size: 17)

extension ChatMessageCellStyle {
    
    static let basicStyle = ChatMessageCellStyle(
        incomingTextStyle: .init(
            textStyle: .init(textColor: .white),
            textPadding: 12,
            attributedTextStyle: .init(textColor: .black),
            cellBackgroundColor: Color.backdrop,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
        ),
        outgoingTextStyle: .init(
            textStyle: .init(textColor: .white),
            textPadding: 12,
            cellBackgroundColor: Color.backdrop,
            cellBorderWidth: 0,
            cellShadowRadius: 0,
            cellRoundedCorners: [.allCorners]
            
        ),
        incomingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 5,
                                                     shadowColor: Color.clear)),
        outgoingAvatarStyle: .init(imageStyle: .init(imageSize: CGSize(width: 32, height: 32),
                                                     cornerRadius: 16,
                                                     borderColor: Color.clear,
                                                     borderWidth: 0,
                                                     shadowRadius: 5,
                                                     shadowColor: Color.clear))
    )
    
}


extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
     
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
     
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func getAverageColor(completion: @escaping (UIColor?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let inputImage = CIImage(image: self) else {
                completion(nil)
                return
            }
            let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
         
            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else {
                completion(nil)
                return
            }
            guard let outputImage = filter.outputImage else {
                completion(nil)
                return
            }
            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull])
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
            completion(UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255))
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    func resize(width: CGFloat) -> UIImage {
        return resize(to: CGSize(width: width, height: width / (size.width / size.height)))
    }
    func resize(height: CGFloat) -> UIImage {
        return resize(to: CGSize(width: height * (size.width / size.height), height: height))
    }
}
