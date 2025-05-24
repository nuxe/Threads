import Foundation
import Dependencies
import OpenAI

struct OpenAIClient {
    var sendMessage: @Sendable ([Message]) async throws -> AsyncThrowingStream<String, Error>
    var generateTitle: @Sendable ([Message]) async throws -> String
}

extension OpenAIClient: DependencyKey {
    static let liveValue = OpenAIClient(
        sendMessage: { messages in
            // TODO: Implement OpenAI chat completion with streaming
            AsyncThrowingStream { continuation in
                continuation.yield("Mock response")
                continuation.finish()
            }
        },
        generateTitle: { messages in
            // TODO: Implement OpenAI title generation
            "New Chat"
        }
    )
    
    static let testValue = OpenAIClient(
        sendMessage: { _ in
            AsyncThrowingStream { continuation in
                continuation.yield("Test response")
                continuation.finish()
            }
        },
        generateTitle: { _ in
            "Test Chat"
        }
    )
}

extension DependencyValues {
    var openAIClient: OpenAIClient {
        get { self[OpenAIClient.self] }
        set { self[OpenAIClient.self] = newValue }
    }
} 