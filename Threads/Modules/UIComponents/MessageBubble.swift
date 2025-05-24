import SwiftUI

struct MessageBubble: View {
    let message: Message
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.role == .user ? Color.blue : Color(.systemGray5))
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .overlay(
                        Group {
                            if message.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .scaleEffect(0.7)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .onLongPressGesture {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    onDelete()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(alert, animated: true)
                }
            }
            
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageBubble(
            message: Message(
                threadID: UUID(),
                role: .assistant,
                content: "Hello! How can I help you today?"
            ),
            onDelete: {}
        )
        
        MessageBubble(
            message: Message(
                threadID: UUID(),
                role: .user,
                content: "I need help with SwiftUI"
            ),
            onDelete: {}
        )
    }
    .padding()
} 