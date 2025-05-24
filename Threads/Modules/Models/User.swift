import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let displayName: String?
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        email: String,
        displayName: String? = nil,
        avatarURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 