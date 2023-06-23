import Foundation
import OpenAISwift


class OpenAIManager {
    static let shared = OpenAIManager()

    private let openAI = OpenAISwift(authToken: "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")

    private init () {}

    public func getEmbedding (inputString: String, completion: @escaping (Result < [Double]?, OpenAIError>) -> Void) {
        openAI.sendEmbeddings(with: inputString, model: .embedding(.ada)) { result in
            switch result {
            case . success (let embedding):
                let vector = embedding.data?.compactMap { $0.embedding }.first
                completion (.success (vector))
            case . failure (let error):
                completion (.failure (error))
            }
        }
    }
}

