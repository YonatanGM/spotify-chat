//
//  TopTracksView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI

//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct TopTracksView: View {
    var topTracksResponse: TopTracksResponse
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ForEach(topTracksResponse.items, id: \.id) { track in
                
                
            }
    
        }
        
    }
}

struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView(topTracksResponse: TopTracksResponse(items: []))
    }
}

