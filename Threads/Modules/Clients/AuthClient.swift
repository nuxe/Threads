import Foundation
import Dependencies
import Supabase
import Auth

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
            let response = try await SupabaseManager.shared.client.auth.signUp(
                email: email,
                password: password
            )
            
            guard let user = response.user else {
                throw AuthError.signUpFailed
            }
            
            // Create or update profile
            if let displayName = email.split(separator: "@").first {
                let profile: [String: Any] = [
                    "id": user.id.uuidString,
                    "display_name": String(displayName)
                ]
                
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .upsert(profile)
                    .execute()
            }
            
            return User(
                id: user.id,
                email: user.email ?? email,
                displayName: email.split(separator: "@").first.map(String.init)
            )
        },
        signIn: { email, password in
            let response = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            
            guard let user = response.user else {
                throw AuthError.signInFailed
            }
            
            // Fetch profile
            let profiles: [Profile] = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .execute()
                .value
            
            let displayName = profiles.first?.displayName
            
            return User(
                id: user.id,
                email: user.email ?? email,
                displayName: displayName
            )
        },
        signOut: {
            try await SupabaseManager.shared.client.auth.signOut()
        },
        getCurrentUser: {
            guard let user = try await SupabaseManager.shared.client.auth.user() else {
                return nil
            }
            
            // Fetch profile
            let profiles: [Profile] = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .execute()
                .value
            
            let displayName = profiles.first?.displayName
            
            return User(
                id: user.id,
                email: user.email ?? "",
                displayName: displayName
            )
        },
        getSession: {
            try await SupabaseManager.shared.client.auth.session
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

// MARK: - Supporting Types

private struct Profile: Codable {
    let id: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

enum AuthError: LocalizedError {
    case signUpFailed
    case signInFailed
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed:
            return "Failed to create account. Please try again."
        case .signInFailed:
            return "Failed to sign in. Please check your credentials."
        }
    }
} 