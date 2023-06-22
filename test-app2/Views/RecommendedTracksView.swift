//
//  RecommendedTracksView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 22.06.23.
//

import SwiftUI

struct RecommendedTracksView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.scenePhase) private var scenePhase
    var tracks: [Track]
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top) {
                ForEach(tracks, id: \.id) { track in
                    TrackCard(track: track)
                        .padding(.horizontal, 1)
                        .padding(.leading, track.id == tracks.first?.id ? 10 : 0)
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

