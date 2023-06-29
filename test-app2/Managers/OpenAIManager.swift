import Foundation
//import OpenAISwift
import OpenAI
//
//class OpenAIManager {
//    static let shared = OpenAIManager()
//
//    let openAI = OpenAISwift(authToken: "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")
//
//    private init () {}
//
//    public func getEmbedding (inputString: String, completion: @escaping (Result < [Double]?, OpenAIError>) -> Void) {
//        openAI.sendEmbeddings(with: inputString, model: .embedding(.ada)) { result in
//            switch result {
//            case . success (let embedding):
//                let vector = embedding.data?.compactMap { $0.embedding }.first
//                completion (.success (vector))
//            case . failure (let error):
//                completion (.failure (error))
//            }
//        }
//    }
//}


class OpenAIManager {
    static let shared = OpenAIManager()
    let openAI = OpenAI(apiToken: "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")

//    let openAI = OpenAISwift(authToken: "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")

    private init () {}

    public func getEmbedding(inputString: String, completion: @escaping (Result<[Double]?, Error>) -> Void) {
        let query = EmbeddingsQuery(model: .textEmbeddingAda, input: inputString)
        self.openAI.embeddings(query: query) { result in
            switch result {
            case .success(let embedding):
                let vector = embedding.data.compactMap { $0.embedding }.first
                completion(.success(vector))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
}

