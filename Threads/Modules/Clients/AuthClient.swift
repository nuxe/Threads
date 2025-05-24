import Foundation
import Dependencies
import Supabase

struct AuthClient {
    var signUp: @Sendable (String, String) async throws -> User
    var signIn: @Sendable (String, String) async throws -> User
    var signOut: @Sendable () async throws -> Void
    var getCurrentUser: @Sendable () async throws -> User?
    var getSession: @Sendable () async throws -> Session?
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        signUp: { email, password in
            // TODO: Implement Supabase signup
            throw NSError(domain: "AuthClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        signIn: { email, password in
            // TODO: Implement Supabase signin
            throw NSError(domain: "AuthClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        signOut: {
            // TODO: Implement Supabase signout
            throw NSError(domain: "AuthClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
        },
        getCurrentUser: {
            // TODO: Implement get current user
            return nil
        },
        getSession: {
            // TODO: Implement get session
            return nil
        }
    )
    
    static let testValue = AuthClient(
        signUp: { _, _ in
            User(email: "test@example.com")
        },
        signIn: { _, _ in
            User(email: "test@example.com")
        },
        signOut: {},
        getCurrentUser: {
            User(email: "test@example.com")
        },
        getSession: {
            nil
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
} 