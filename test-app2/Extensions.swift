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


