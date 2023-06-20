import Foundation


// Define a class for the openai operations
class OpenAIManager {
    
    // Define a static property that holds the shared instance
    static let shared = OpenAIManager()
    
    // Define a private initializer to prevent creating other instances
    private init() {}
    
    // Define the constant for the openai key
    let openaiKey = "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"
    
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
        request.setValue("Bearer \(openaiKey)", forHTTPHeaderField: "Authorization")
        
        // Return the request object
        return request
    }
    
    // Define the function for getting embeddings as a class method
    func getEmbedding(inputString: String, completion: @escaping ([Double]?, Error?) -> Void) {
        // Set the parameters for the request
        let parameters: [String: Any] = [
            "input": inputString,
            "model": "text-embedding-ada-002"
        ]
        
        // Create a url request object using the helper function
        guard let request = createRequest(urlString: "https://api.openai.com/v1/embeddings", parameters: parameters) else {
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
                
                // Extract the embedding vector from the JSON data
                guard let embedding = json?["data"] as? [[String: Any]],
                      let vector = embedding.first?["embedding"] as? [Double] else {
                    // Call the completion handler with nil and a custom error
                    completion(nil, URLError(.cannotDecodeContentData))
                    return
                }
                
                // Call the completion handler with the vector and nil error
                completion(vector, nil)
                
            } catch {
                // Call the completion handler with nil and the decoding error
                completion(nil, error)
            }
        }
        
        // Resume the task
        task.resume()
    }
}
