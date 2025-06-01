import Foundation

struct Thread: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    let userID: UUID
    let createdAt: Date
    let updatedAt: Date
    let lastMessageAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        userID: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastMessageAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.userID = userID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessageAt = lastMessageAt
    }
} 