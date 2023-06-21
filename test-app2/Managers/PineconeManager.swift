import Foundation

class PineconeManager {
    
    static let shared = PineconeManager()
    
    let headers = [
        "accept": "application/json",
        "content-type": "application/json",
        "Api-Key": "f6bbdc2b-0e92-4493-ae94-04a329343bdf"
    ]
    
    let baseUrl = "https://user-preferences-embeddings-index-d2e3d6c.svc.asia-southeast1-gcp-free.pinecone.io"
    
    private init () {}
    
    public func insertEmbeddings(vectors: [String: [Double]], namespace: String, completion: @escaping (Bool?, Error?) -> Void) {
        // Initialize an empty array to store the vectors for the request
        var vectorArray = [[String: Any]]()
        for (id, values) in vectors {
            vectorArray.append(["id": id, "values": values])
        }
        // Construct the parameters for the request using the array
        var parameters = ["vectors": vectorArray] as [String : Any]
        parameters["namespace"] = namespace
        
        
        // use a do-catch block to create the postData
        var postData: Data?
        
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // handle any errors that might occur when creating the postData
            print(error.localizedDescription)
            // call the completion closure with nil and error
            completion(nil, error)
            return
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "\(baseUrl)/vectors/upsert")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(false, error)
            } else {
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false, nil)
                    return
                }
                completion(true, nil)
            }
        })
        
        dataTask.resume()
    }
    
    // other functions ...
    public func queryEmbedding(id: String, /* query: [Double] */ topK: Int, namespace: String, completion: @escaping ([String]?, Error?) -> Void) {
        let parameters = [
            "includeValues": "false",
            "includeMetadata": "false",
            //            "vector": query,
            "namespace": namespace,
            "topK": topK,
            "id": id
        ] as [String : Any]
        
        // use a do-catch block to create the postData
        var postData: Data?
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // handle any errors that might occur when creating the postData
            print(error.localizedDescription)
            completion(nil, error)
            return
        }
        
        guard let url = URL(string: "\(baseUrl)/query") else {
            print("Invalid URL")
            // call the completion closure with nil and an error
            completion(nil, NSError(domain: "URL", code: -1))
            return
        }
        
        let request = NSMutableURLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data  else {
                completion(nil, nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200  else {
                completion(nil, nil)
                return
            }
            
            do {
                // decode the data as a JSON object
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                // cast the JSON object as a dictionary
                guard let dictionary = jsonObject as? [String: Any],
                      let matches = dictionary["matches"] as? [[String: Any]] else {
                    completion(nil, nil)
                    return
                }
                let ids = matches.compactMap { $0["id"] as? String }
                completion(ids, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil, error)
            }
            
        })
        
        dataTask.resume()
    }
    
}
