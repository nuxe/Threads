import Foundation
import Dependencies
import Supabase

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
            // TODO: Implement Supabase thread retrieval
            []
        },
        createThread: { thread in
            // TODO: Implement Supabase thread creation
            thread
        },
        updateThread: { thread in
            // TODO: Implement Supabase thread update
            thread
        },
        deleteThread: { threadID in
            // TODO: Implement Supabase thread deletion
        },
        getMessages: { threadID in
            // TODO: Implement Supabase message retrieval
            []
        },
        createMessage: { message in
            // TODO: Implement Supabase message creation
            message
        },
        deleteMessage: { messageID in
            // TODO: Implement Supabase message deletion
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