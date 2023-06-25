//
//  utils.swift
//  test-app2
//
//  Created by Yonatan Mamo on 21.06.23.
//

import Foundation

func generateDescription(topTrackResponse: TracksResponse?, topArtistsReponse: ArtistsResponse?, topRecentTracksResponse: TracksResponse? = nil) -> String {
    var description = "Likes:"
    for track in topTrackResponse?.items.prefix(10) ?? [] {
        // Get the track name, album name and artist name
        let trackName = track.name
        let albumName = track.album?.name ?? ""
        let artistName = track.artists.first?.name ?? ""
        
        // Get the genres of the artist from the artist struct
        let genres = track.artists.first?.genres ?? []
        // Use .prefix(3) to get only the first three genres or less
        let genreNames = genres.prefix(3)
        
        // Format the genres as a comma-separated list enclosed in parentheses
        let genreList = genreNames.joined(separator: ", ")
        
        let genreString = "(\(genreList))"
        
        // Append the track information to the description
        if genreNames.isEmpty {
            description += " '\(trackName)' from '\(albumName)' by \(artistName),"
        } else {
            description += " '\(trackName)' from '\(albumName)' by \(artistName) \(genreString),"
        }
    }
    
    for track in topRecentTracksResponse?.items.prefix(15) ?? [] {
        // Get the track name, album name and artist name
        let trackName = track.name
        let albumName = track.album?.name ?? ""
        let artistName = track.artists.first?.name ?? ""
        
        // Get the genres of the artist from the artist struct
        let genres = track.artists.first?.genres ?? []
        // Use .prefix(3) to get only the first three genres or less
        let genreNames = genres.prefix(3)
        
        // Format the genres as a comma-separated list enclosed in parentheses
        let genreList = genreNames.joined(separator: ", ")
        
        let genreString = "(\(genreList))"
        
        // Append the track information to the description
        if genreNames.isEmpty {
            description += " '\(trackName)' from '\(albumName)' by \(artistName),"
        } else {
            description += " '\(trackName)' from '\(albumName)' by \(artistName) \(genreString),"
        }
    }
    
    // Add a new line to separate the sections
    
    description += "\n"
    
    // Get the top 10 genres from the top artists response
    var topGenres = [String]()
    
    for artist in topArtistsReponse?.items.prefix(10) ?? [] {
        for genre in artist.genres ?? [] {
            // Avoid adding duplicate genres to the list
            if !topGenres.contains(genre) {
                topGenres.append(genre)
            }
        }
    }
    
    // Format the top genres as a comma-separated list
    let topGenreList = topGenres.prefix(10).joined(separator: ", ")
    
    // Get the top 10 artist names from the top artists response
    var topArtists = [String]()
    for artist in topArtistsReponse?.items.prefix(10) ?? [] {
        topArtists.append(artist.name)
    }
    
    // Format the top artists as a comma-separated list
    let topArtistList = topArtists.joined(separator: ", ")
    
    // Add the section with the wording you chose
    description += "Also enjoys the genres: \(topGenreList), and loves listening to: \(topArtistList)."
    
    return description
}
