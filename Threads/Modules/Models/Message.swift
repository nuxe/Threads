import Foundation

enum MessageRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system
}

struct Message: Codable, Identifiable, Equatable {
    let id: UUID
    let threadID: UUID
    let role: MessageRole
    let content: String
    let createdAt: Date
    let isLoading: Bool
    
    init(
        id: UUID = UUID(),
        threadID: UUID,
        role: MessageRole,
        content: String,
        createdAt: Date = Date(),
        isLoading: Bool = false
    ) {
        self.id = id
        self.threadID = threadID
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.isLoading = isLoading
    }
    
    // Helper for creating user messages
    static func userMessage(threadID: UUID, content: String) -> Message {
        Message(threadID: threadID, role: .user, content: content)
    }
    
    // Helper for creating assistant messages
    static func assistantMessage(threadID: UUID, content: String) -> Message {
        Message(threadID: threadID, role: .assistant, content: content)
    }
    
    // Helper for creating loading messages
    static func loadingMessage(threadID: UUID) -> Message {
        Message(threadID: threadID, role: .assistant, content: "", isLoading: true)
    }
} 