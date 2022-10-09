//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit



// horizontal scrollable view of the tracks following spotify design guideline
struct TopTracksView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.scenePhase) private var scenePhase
    var tracks: [Track]
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top) {
                ForEach(tracks, id: \.id) { track in
                    TrackCard(track: track)

                }
            }
        }
        .frame(height: 380) // hardcoding this till i find a better way
        .onDisappear {
            model.removePlayer()
        }
        .onChange(of: scenePhase) { phase in
            model.handlePlackbackOnChangeOfScenePhase(to: phase)

        }
    }
}
