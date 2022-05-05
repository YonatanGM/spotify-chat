//
//  APICaller.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import Foundation


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
    
    public func getUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    // let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    // print(result)
                    completion(.success(result))
                    
                } catch {
                    print(error.localizedDescription)
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
    
    public func getTopArtists(timeRange: TimeRange = .long_term, completion: @escaping (Result<TopArtistsResponse, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/artists?limit=50&time_range=\(timeRange.rawValue)"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TopArtistsResponse.self, from: data)
                    // let result = try JSONSerialization.jsonObject(with: data)
                    print(result.items.map { $0.name })
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
            
        }
    }
    
    public func getTopTracks(timeRange: TimeRange = .long_term, completion: @escaping (Result<TopTracksResponse, Error>) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/tracks?limit=50&time_range=\(timeRange.rawValue)"),
                      type: .GET) { request in
   
            // execute the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TopTracksResponse.self, from: data)
                    // let result = try JSONSerialization.jsonObject(with: data)
                    print(result.items.map { $0.name })
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        
        }
    }

}
