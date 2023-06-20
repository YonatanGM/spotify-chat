//
//  PineconeManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 20.06.23.
//

import Foundation

// Define a class for the pinecone operations
class PineconeManager {
    
    // Define a static property that holds the shared instance
    static let shared = PineconeManager()
    
    // Define a private initializer to prevent creating other instances
    private init() {}
    
    // Define the constant for the pinecone key and index name
    let pineconeKey = "f6bbdc2b-0e92-4493-ae94-04a329343bdf"
    let pineconeIndex = "user-preferences-embeddings-index"
    
    // Define a helper function to create a url request object
    func createRequest(urlString: String, parameters: [String: Any]) -> URLRequest? {
        // Create a url object from the string
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        // Create a url request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Encode the parameters as JSON data
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        // Set the content type and authorization headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ApiKey \(pineconeKey)", forHTTPHeaderField: "Authorization")
        
        // Return the request object
        return request
    }
    
    // Define the function for inserting embeddings as a class method
    func insertEmbedding(embedding: [Double], vector_id: String, completion: @escaping (Bool?, Error?) -> Void) {
        // Set the parameters for the request
        let parameters: [String: Any] = [
            "vectors": [
                [
                    "id": vector_id,
                    "values": embedding
                ]
            ]
        ]
        
        // Create a url request object using the helper function
        guard let request = createRequest(urlString: "https://api.pinecone.io/v1/\(pineconeIndex)/upsert", parameters: parameters) else {
            // Call the completion handler with nil and a custom error
            completion(nil, URLError(.badURL))
            return
        }
        
        // Create a data task with the request and a completion handler
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check if there is an error
            if let error = error {
                // Call the completion handler with nil and error
                completion(nil, error)
                return
            }
            
            // Check if the response is successful (status code 200)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                // Call the completion handler with nil and a custom error
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            // Check if there is data
            guard let data = data else {
                // Call the completion handler with nil and a custom error
                completion(nil, URLError(.cannotDecodeContentData))
                return
            }
            
            // Decode the data as JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                // Extract the success flag from the JSON data
                guard let success = json?["success"] as? Bool else {
                    // Call the completion handler with nil and a custom error
                    completion(nil, URLError(.cannotDecodeContentData))
                    return
                }
                
                // Call the completion handler with the success flag and nil error
                completion(success, nil)
                
            } catch {
                // Call the completion handler with nil and the decoding error
                completion(nil, error)
            }
        }
        
        // Resume the task
        task.resume()
    }
    
    // Define a function for querying embeddings as a class method
    func queryEmbedding(embedding: [Double], top_k: Int, completion: @escaping ([String]?, Error?) -> Void) {
        // Set the parameters for the request
        let parameters: [String: Any] = [
            "vector": embedding,
            "top_k": top_k
        ]
        
        // Create a url request object using the helper function
        guard let request = createRequest(urlString: "https://api.pinecone.io/v1/\(pineconeIndex)/query", parameters: parameters) else {
            // Call the completion handler with nil and a custom error
            completion(nil, URLError(.badURL))
            return
        }
        
        // Create a data task with the request and a completion handler
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check if there is an error
            if let error = error {
                // Call the completion handler with nil and error
                completion(nil, error)
                return
            }
            
            // Check if the response is successful (status code 200)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                // Call the completion handler with nil and a custom error
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            // Check if there is data
            guard let data = data else {
                // Call the completion handler with nil and a custom error
                completion(nil, URLError(.cannotDecodeContentData))
                return
            }
            
            // Decode the data as JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                // Extract the matches array from the JSON data
                guard let matches = json?["matches"] as? [[String: Any]] else {
                    // Call the completion handler with nil and a custom error
                    completion(nil, URLError(.cannotDecodeContentData))
                    return
                }
                
                // Extract the ids from the matches array
                let ids = matches.map { $0["id"] as? String }.compactMap { $0 }
                
                // Call the completion handler with the ids array and nil error
                completion(ids, nil)
                
            } catch {
                // Call the completion handler with nil and the decoding error
                completion(nil, error)
            }
        }
        
        // Resume the task
        task.resume()
    }
}
