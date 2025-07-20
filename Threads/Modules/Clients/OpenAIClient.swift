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
            AsyncThrowingStream { continuation in
                Task {
                    do {
                        // Convert messages to OpenAI format
                        let chatMessages = messages.map { message in
                            ChatQuery.ChatCompletionMessageParam(
                                role: message.role == .user ? .user : .assistant,
                                content: message.content
                            )!
                        }
                        
                        // Initialize OpenAI client with API key
                        guard let apiKey = ConfigurationManager.shared.openAIAPIKey else {
                            throw OpenAIError.missingAPIKey
                        }
                        
                        let openAI = OpenAI(apiToken: apiKey)
                        
                        // Create chat query
                        let query = ChatQuery(
                            messages: chatMessages,
                            model: .gpt4o_mini,
                            stream: true
                        )
                        
                        // Stream the response
                        let stream = openAI.chatsStream(query: query)

                        for try await result in stream {
                            if let content = result.choices.first?.delta.content {
                                continuation.yield(content)
                            }
                        }
                        
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        },
        generateTitle: { messages in
            // Get first few messages for context
            let contextMessages = Array(messages.prefix(4))
            
            // Convert to OpenAI format
            var chatMessages = contextMessages.map { message in
                ChatQuery.ChatCompletionMessageParam(
                    role: message.role == .user ? .user : .assistant,
                    content: message.content
                )!
            }
            
            // Add system message for title generation
            let systemMessage = ChatQuery.ChatCompletionMessageParam(
                role: .system,
                content: "Generate a concise, descriptive title (max 5 words) for this conversation. Return only the title, no quotes or punctuation."
            )!
            
            chatMessages.insert(systemMessage, at: 0)
            
            // Initialize OpenAI client
            guard let apiKey = ConfigurationManager.shared.openAIAPIKey else {
                throw OpenAIError.missingAPIKey
            }
            
            let openAI = OpenAI(apiToken: apiKey)
            
            // Create query
            let query = ChatQuery(
                messages: chatMessages,
                model: .gpt4o_mini,
                temperature: 0.7,
                maxTokens: 20
            )
            
            // Get response
            let result = try await openAI.chats(query: query)
            
            guard let title = result.choices.first?.message.content?.string else {
                return "New Chat"
            }
            
            // Clean up the title
            let cleanedTitle = title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            return cleanedTitle.isEmpty ? "New Chat" : cleanedTitle
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

// MARK: - Errors

enum OpenAIError: LocalizedError {
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not configured. Please configure it in Settings."
        }
    }
} 