import Foundation
import Dependencies
import Supabase
import PostgREST

struct SupabaseClient {
    var getThreads: @Sendable (UUID) async throws -> [Thread]
    var createThread: @Sendable (Thread) async throws -> Thread
    var updateThread: @Sendable (Thread) async throws -> Thread
    var deleteThread: @Sendable (UUID) async throws -> Void
    var getMessages: @Sendable (UUID) async throws -> [Message]
    var createMessage: @Sendable (Message) async throws -> Message
    var deleteMessage: @Sendable (UUID) async throws -> Void
}

extension SupabaseClient: DependencyKey {
    static let liveValue = SupabaseClient(
        getThreads: { userID in
            let threads: [ThreadDTO] = try await SupabaseManager.shared.client
                .from("threads")
                .select()
                .eq("user_id", value: userID.uuidString)
                .order("last_message_at", ascending: false)
                .execute()
                .value
            
            return threads.map { $0.toThread() }
        },
        createThread: { thread in
            let dto = ThreadDTO(from: thread)
            
            let response: [ThreadDTO] = try await SupabaseManager.shared.client
                .from("threads")
                .insert(dto)
                .select()
                .execute()
                .value
            
            guard let created = response.first else {
                throw DatabaseError.insertFailed
            }
            
            return created.toThread()
        },
        updateThread: { thread in
            let updates: [String: Any] = [
                "title": thread.title,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ]
            
            let response: [ThreadDTO] = try await SupabaseManager.shared.client
                .from("threads")
                .update(updates)
                .eq("id", value: thread.id.uuidString)
                .select()
                .execute()
                .value
            
            guard let updated = response.first else {
                throw DatabaseError.updateFailed
            }
            
            return updated.toThread()
        },
        deleteThread: { threadID in
            try await SupabaseManager.shared.client
                .from("threads")
                .delete()
                .eq("id", value: threadID.uuidString)
                .execute()
        },
        getMessages: { threadID in
            let messages: [MessageDTO] = try await SupabaseManager.shared.client
                .from("messages")
                .select()
                .eq("thread_id", value: threadID.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            return messages.map { $0.toMessage() }
        },
        createMessage: { message in
            let dto = MessageDTO(from: message)
            
            let response: [MessageDTO] = try await SupabaseManager.shared.client
                .from("messages")
                .insert(dto)
                .select()
                .execute()
                .value
            
            guard let created = response.first else {
                throw DatabaseError.insertFailed
            }
            
            return created.toMessage()
        },
        deleteMessage: { messageID in
            try await SupabaseManager.shared.client
                .from("messages")
                .delete()
                .eq("id", value: messageID.uuidString)
                .execute()
        }
    )
    
    static let testValue = SupabaseClient(
        getThreads: { _ in [] },
        createThread: { $0 },
        updateThread: { $0 },
        deleteThread: { _ in },
        getMessages: { _ in [] },
        createMessage: { $0 },
        deleteMessage: { _ in }
    )
}

extension DependencyValues {
    var supabaseClient: SupabaseClient {
        get { self[SupabaseClient.self] }
        set { self[SupabaseClient.self] = newValue }
    }
}

// MARK: - Data Transfer Objects

private struct ThreadDTO: Codable {
    let id: String
    let userId: String
    let title: String
    let createdAt: String
    let updatedAt: String
    let lastMessageAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastMessageAt = "last_message_at"
    }
    
    init(from thread: Thread) {
        let formatter = ISO8601DateFormatter()
        self.id = thread.id.uuidString
        self.userId = thread.userID.uuidString
        self.title = thread.title
        self.createdAt = formatter.string(from: thread.createdAt)
        self.updatedAt = formatter.string(from: thread.updatedAt)
        self.lastMessageAt = thread.lastMessageAt.map { formatter.string(from: $0) }
    }
    
    func toThread() -> Thread {
        let formatter = ISO8601DateFormatter()
        return Thread(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            userID: UUID(uuidString: userId) ?? UUID(),
            createdAt: formatter.date(from: createdAt) ?? Date(),
            updatedAt: formatter.date(from: updatedAt) ?? Date(),
            lastMessageAt: lastMessageAt.flatMap { formatter.date(from: $0) }
        )
    }
}

private struct MessageDTO: Codable {
    let id: String
    let threadId: String
    let role: String
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case threadId = "thread_id"
        case role
        case content
        case createdAt = "created_at"
    }
    
    init(from message: Message) {
        let formatter = ISO8601DateFormatter()
        self.id = message.id.uuidString
        self.threadId = message.threadID.uuidString
        self.role = message.role.rawValue
        self.content = message.content
        self.createdAt = formatter.string(from: message.createdAt)
    }
    
    func toMessage() -> Message {
        let formatter = ISO8601DateFormatter()
                            return Message(
            id: UUID(uuidString: id) ?? UUID(),
            threadID: UUID(uuidString: threadId) ?? UUID(),
            role: MessageRole(rawValue: role) ?? .user,
            content: content,
            createdAt: formatter.date(from: createdAt) ?? Date(),
            status: .sent // Messages from database are considered sent
        )
    }
}

// MARK: - Errors

enum DatabaseError: LocalizedError {
    case insertFailed
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .insertFailed:
            return "Failed to save data. Please try again."
        case .updateFailed:
            return "Failed to update data. Please try again."
        }
    }
} 