import Foundation
import Dependencies
import Supabase
import Realtime

struct RealtimeManager {
    var subscribeToMessages: @Sendable (UUID, @escaping (Message) -> Void, @escaping (UUID) -> Void) async throws -> RealtimeChannelV2
    var subscribeToThreads: @Sendable (UUID, @escaping (Thread) -> Void, @escaping (UUID) -> Void) async throws -> RealtimeChannelV2
    var unsubscribe: @Sendable (RealtimeChannelV2) async -> Void
}

extension RealtimeManager: DependencyKey {
    static let liveValue = RealtimeManager(
        subscribeToMessages: { threadID, onInsert, onDelete in
            let channel = SupabaseManager.shared.client.realtimeV2.channel("messages:\(threadID.uuidString)")
            
            let insertSubscription = await channel.onPostgresChanges(
                AnyAction.insert,
                schema: "public",
                table: "messages",
                filter: "thread_id=eq.\(threadID.uuidString)"
            ) { payload in
                if let record = payload.record,
                   let messageDTO = try? JSONDecoder().decode(MessageDTO.self, from: JSONSerialization.data(withJSONObject: record)) {
                    let message = messageDTO.toMessage()
                    onInsert(message)
                }
            }
            
            let deleteSubscription = await channel.onPostgresChanges(
                AnyAction.delete,
                schema: "public", 
                table: "messages",
                filter: "thread_id=eq.\(threadID.uuidString)"
            ) { payload in
                if let oldRecord = payload.oldRecord,
                   let idString = oldRecord["id"] as? String,
                   let messageID = UUID(uuidString: idString) {
                    onDelete(messageID)
                }
            }
            
            await channel.subscribe()
            return channel
        },
        subscribeToThreads: { userID, onUpdate, onDelete in
            let channel = SupabaseManager.shared.client.realtimeV2.channel("threads:\(userID.uuidString)")
            
            let updateSubscription = await channel.onPostgresChanges(
                AnyAction.update,
                schema: "public",
                table: "threads", 
                filter: "user_id=eq.\(userID.uuidString)"
            ) { payload in
                if let record = payload.record,
                   let threadDTO = try? JSONDecoder().decode(ThreadDTO.self, from: JSONSerialization.data(withJSONObject: record)) {
                    let thread = threadDTO.toThread()
                    onUpdate(thread)
                }
            }
            
            let deleteSubscription = await channel.onPostgresChanges(
                AnyAction.delete,
                schema: "public",
                table: "threads",
                filter: "user_id=eq.\(userID.uuidString)"
            ) { payload in
                if let oldRecord = payload.oldRecord,
                   let idString = oldRecord["id"] as? String,
                   let threadID = UUID(uuidString: idString) {
                    onDelete(threadID)
                }
            }
            
            await channel.subscribe()
            return channel
        },
        unsubscribe: { channel in
            await channel.unsubscribe()
        }
    )
    
    static let testValue = RealtimeManager(
        subscribeToMessages: { _, _, _ in 
            // Return a mock channel
            SupabaseManager.shared.client.realtimeV2.channel("test")
        },
        subscribeToThreads: { _, _, _ in
            SupabaseManager.shared.client.realtimeV2.channel("test")
        },
        unsubscribe: { _ in }
    )
}

extension DependencyValues {
    var realtimeManager: RealtimeManager {
        get { self[RealtimeManager.self] }
        set { self[RealtimeManager.self] = newValue }
    }
}

// MARK: - Supporting Types

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
    
    func toMessage() -> Message {
        let formatter = ISO8601DateFormatter()
        return Message(
            id: UUID(uuidString: id) ?? UUID(),
            threadID: UUID(uuidString: threadId) ?? UUID(),
            role: MessageRole(rawValue: role) ?? .user,
            content: content,
            createdAt: formatter.date(from: createdAt) ?? Date(),
            status: .sent // Messages from realtime are considered sent
        )
    }
}

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