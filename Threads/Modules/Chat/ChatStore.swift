import Foundation
import ComposableArchitecture

@Reducer
struct ChatStore {
    @ObservableState
    struct State: Equatable {
        var thread: Thread
        var messages: [Message] = []
        var messageText = ""
        var isLoading = false
        var isStreaming = false
        var errorMessage: String?
        
        init(thread: Thread) {
            self.thread = thread
        }
    }
    
    enum Action {
        case onAppear
        case loadMessages
        case sendMessage
        case messageTextChanged(String)
        case deleteMessage(UUID)
        case goBack
        
        // Internal actions
        case loadMessagesResponse(Result<[Message], Error>)
        case sendMessageResponse(Result<Message, Error>)
        case streamingResponse(String)
        case streamingComplete
        case streamingError(Error)
        case deleteMessageResponse(Result<UUID, Error>)
        case threadUpdated(Thread)
    }
    
    @Dependency(\.supabaseClient) var supabaseClient
    @Dependency(\.openAIClient) var openAIClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadMessages)
                
            case .loadMessages:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [threadID = state.thread.id] send in
                    await send(.loadMessagesResponse(Result {
                        try await supabaseClient.getMessages(threadID)
                    }))
                }
                
            case .sendMessage:
                guard !state.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .none
                }
                
                let userMessage = Message.userMessage(
                    threadID: state.thread.id,
                    content: state.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                let loadingMessage = Message.loadingMessage(threadID: state.thread.id)
                
                state.messages.append(userMessage)
                state.messages.append(loadingMessage)
                state.messageText = ""
                state.isStreaming = true
                
                return .run { [messages = state.messages] send in
                    // Save user message
                    await send(.sendMessageResponse(Result {
                        try await supabaseClient.createMessage(userMessage)
                    }))
                    
                    // Get AI response with streaming
                    do {
                        let stream = try await openAIClient.sendMessage(messages.filter { !$0.isLoading })
                        for try await chunk in stream {
                            await send(.streamingResponse(chunk))
                        }
                        await send(.streamingComplete)
                    } catch {
                        await send(.streamingError(error))
                    }
                }
                
            case let .messageTextChanged(text):
                state.messageText = text
                return .none
                
            case let .deleteMessage(messageID):
                return .run { send in
                    await send(.deleteMessageResponse(Result {
                        try await supabaseClient.deleteMessage(messageID)
                        return messageID
                    }))
                }
                
            case .goBack:
                // This will be handled by parent coordinator
                return .none
                
            // Response actions
            case let .loadMessagesResponse(.success(messages)):
                state.isLoading = false
                state.messages = messages.sorted { $0.createdAt < $1.createdAt }
                return .none
                
            case let .loadMessagesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .sendMessageResponse(.success(message)):
                // Message already added to state, just update with saved version if needed
                if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
                    state.messages[index] = message
                }
                return .none
                
            case let .sendMessageResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .streamingResponse(chunk):
                // Update the loading message with streamed content
                if let loadingIndex = state.messages.lastIndex(where: { $0.isLoading }) {
                    var updatedMessage = state.messages[loadingIndex]
                    updatedMessage = Message(
                        id: updatedMessage.id,
                        threadID: updatedMessage.threadID,
                        role: .assistant,
                        content: updatedMessage.content + chunk,
                        createdAt: updatedMessage.createdAt,
                        isLoading: true
                    )
                    state.messages[loadingIndex] = updatedMessage
                }
                return .none
                
            case .streamingComplete:
                state.isStreaming = false
                // Convert loading message to final message
                if let loadingIndex = state.messages.lastIndex(where: { $0.isLoading }) {
                    var finalMessage = state.messages[loadingIndex]
                    finalMessage = Message(
                        id: finalMessage.id,
                        threadID: finalMessage.threadID,
                        role: .assistant,
                        content: finalMessage.content,
                        createdAt: finalMessage.createdAt,
                        isLoading: false
                    )
                    state.messages[loadingIndex] = finalMessage
                    
                    // Save final message to database and generate title if needed
                    return .run { [messages = state.messages, thread = state.thread] send in
                        await send(.sendMessageResponse(Result {
                            try await supabaseClient.createMessage(finalMessage)
                        }))
                        
                        // Generate title if this is the first conversation and title is still "New Chat"
                        if thread.title == "New Chat" && messages.count >= 2 {
                            do {
                                let title = try await openAIClient.generateTitle(messages)
                                var updatedThread = thread
                                updatedThread.title = title
                                let updated = try await supabaseClient.updateThread(updatedThread)
                                await send(.threadUpdated(updated))
                            } catch {
                                // Silently fail title generation - not critical
                                print("Failed to generate title: \(error)")
                            }
                        }
                    }
                }
                return .none
                
            case let .streamingError(error):
                state.isStreaming = false
                state.errorMessage = error.localizedDescription
                // Remove the loading message on error
                state.messages.removeAll { $0.isLoading }
                return .none
                
            case let .deleteMessageResponse(.success(messageID)):
                state.messages.removeAll { $0.id == messageID }
                return .none
                
            case let .deleteMessageResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .threadUpdated(thread):
                state.thread = thread
                return .none
            }
        }
    }
} 
