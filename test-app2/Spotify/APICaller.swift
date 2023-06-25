//
//  APICaller.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation
import Promises

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case  failedToGetData
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    private func createRequest(with url:  URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            
            
            guard let apiURL = url else {
                return
            }
            
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30 // 30 seconds timeout time
            completion(request)
        }
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfileResponse, Error>) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                    // let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    // print(result)
                    completion(.success(result))
                    
                } catch {
                    // print(error.localizedDescription)
                    // print(response)
                    // print( print((response as? HTTPURLResponse)?.statusCode))
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    enum TimeRange: String {
        case short_term
        case medium_term
        case long_term
    }
    
    public func getTopArtists(timeRange: TimeRange = .medium_term, limit: Int = 20, completion: @escaping (Result<ArtistsResponse, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/artists?limit=\(limit)&time_range=\(timeRange.rawValue)"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(ArtistsResponse.self, from: data)
                    // print("top artist", result.items.map { $0.name })
                    completion(.success(result))
                } catch {
                    // print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
            
        }
    }

    
    
    public func getTopTracks(timeRange: TimeRange = .medium_term, limit: Int = 20, completion: @escaping (Result<TracksResponse, Error>) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/tracks?limit=\(limit)&time_range=\(timeRange.rawValue)"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TracksResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        
        }
    }
    
    public func getAvailableGenres(completion: @escaping (Result<[String:[String]], Error>) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds/"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    // print("ddd*", data)
                    let result = try JSONDecoder().decode([String:[String]].self, from: data)
                    // print("res*", result["genres"])
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        
        }
    }
    
    
    public func getTopGenres(completition: @escaping (Result<[String], Error>) -> Void) {
        getTopArtists { result in
            switch result {
            case .success(let response):
                let genres = response.items.compactMap { $0.genres }
                let uniqueGenres = genres.reduce([]) {
                    return Set($0).union(Set($1))
                }
                // print("topGenres", uniqueGenres)
                
                completition(.success(Array(uniqueGenres)))
            case .failure(let error):
                completition(.failure(error))
            }
            
        }
    }
    
    
    
    public func getPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/playlists/?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(PlaylistsResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // only interested in the name of playlist
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<Playlist, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id + "?fields=id,name"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(Playlist.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func addToLikedSongs(trackID: String, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/tracks?ids=\(trackID)"),
            type: .PUT
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      error == nil else {
                    // print((response as? HTTPURLResponse)?.statusCode)
                    completion(false)
                    return
                }
                

                completion(true)
            }
            task.resume()
        }
    }
    
    public func removeFromLikedSongs(trackID: String, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/tracks?ids=\(trackID)"),
            type: .DELETE
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
            task.resume()
        }
    }
    

    
    public func followUser(with id: String, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/following?type=user&ids=\(id)"),
            type: .PUT
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // print((response as? HTTPURLResponse)?.statusCode)
                    completion(false)
                    return
                }
                completion(true)
            }
            task.resume()
        }
    }
    
    public func unfollowUser(with id: String, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/following?type=user&ids=\(id)"),
            type: .DELETE
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // print((response as? HTTPURLResponse)?.statusCode)
                    completion(false)
                    return
                }
                completion(true)
            }
            task.resume()
        }
    }
    
    public func checkIfCurrentUserFollowsUsers(with ids: [String], completion: @escaping (Result<[String: Bool], Error>) -> Void) {
      
        
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/following/contains?type=user&ids=\(ids.joined(separator: ","))"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
  
                guard let data = data, error == nil else {
                    
                    if let error = error {
                        // print(error)
                        completion(.failure(error))
                    }
                    return
                }
                do {
                    
                    let result = try JSONDecoder().decode([Bool].self, from: data)
                    
                    completion(.success(Dictionary(uniqueKeysWithValues: zip(ids, result))))
                } catch let error {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func checkIfUserHasSavedTracks(with ids: [String], completion: @escaping (Result<[String: Bool], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/tracks/contains?ids=\(ids.joined(separator: ","))"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // print((response as? HTTPURLResponse)?.statusCode)
                    if let error = error {
                        // print(error)
                        completion(.failure(error))
                    }
                    return
                }
                do {
                    let result = try JSONDecoder().decode([Bool].self, from: data)
                    completion(.success(Dictionary(uniqueKeysWithValues: zip(ids, result))))
                } catch let error {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(seedArtists:[String],
                                   seedGenres: [String],
                                   seedTracks: [String],
                                   limit: Int,
                                   completion: @escaping (Result<[Track], Error>) -> Void) {
        
        let urlString = Constants.baseAPIURL + "/recommendations?limit=\(limit)&seed_artists=\(seedArtists.joined(separator: ","))&seed_genres=\(seedGenres.joined(separator: ","))&seed_tracks=\(seedTracks.joined(separator: ","))"
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: encodedString)
        
        createRequest(
            with: url,
            type: .GET
        ) { request in
            // execute the request

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result.tracks))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        }
    }
    
    
    public func getTopItems(completion: @escaping (Result<(ArtistsResponse, TracksResponse, TracksResponse), Error>) -> Void) {
        
        let topArtistsPromise = Promise<ArtistsResponse> { fulfill, reject in
            APICaller.shared.getTopArtists(limit: 20) { result in
                switch result {
                case .success(let topArtistsResponse):
                    fulfill(topArtistsResponse)
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
        let topTracksPromise = Promise<TracksResponse> { fulfill, reject in
            APICaller.shared.getTopTracks(timeRange: .long_term, limit: 20) { result in
                switch result {
                case .success(let topTracksResponse):
                    fulfill(topTracksResponse)
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
        let topRecentTracksPromise = Promise<TracksResponse> { fulfill, reject in
            APICaller.shared.getTopTracks(timeRange: .short_term, limit: 20) { result in
                switch result {
                case .success(let topRecentTracksResponse):
                    fulfill(topRecentTracksResponse)
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
        Promises.all(topArtistsPromise, topTracksPromise, topRecentTracksPromise)
            .then { topArtistsResponse, topTracksResponse, topRecentTracksResponse in
                completion(.success((topArtistsResponse, topTracksResponse, topRecentTracksResponse)))
                
            }
            .catch { error in
                print("failed to fetch top items from Spotify", error.localizedDescription)
                completion(.failure(error))
            }
    }
    
}
