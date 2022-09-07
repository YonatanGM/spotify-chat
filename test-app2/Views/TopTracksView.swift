//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit



// horizontal scrollable view of the artists following spotify design guideline
struct TopTracksView: View {
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            if let topTracksResponse = model.usersInCurrentRoom.first?.topTracks {
                HStack {
                    ForEach(topTracksResponse.items, id: \.id) { track in
                        TrackCard(track: track)

                    }
                }
            }

        }
        
    }
}

struct TopArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        TopArtistsView()
    }
}
