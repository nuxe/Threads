import SwiftUI

struct ThreadRowView: View {
    let thread: Thread
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastMessageAt = thread.lastMessageAt {
                        Text(lastMessageAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Tap to continue conversation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        ThreadRowView(
            thread: Thread(title: "Swift Development Help", userID: UUID()),
            onTap: {}
        )
        
        ThreadRowView(
            thread: Thread(title: "Recipe Ideas for Dinner Tonight", userID: UUID()),
            onTap: {}
        )
        
        ThreadRowView(
            thread: Thread(title: "Travel Planning", userID: UUID()),
            onTap: {}
        )
    }
} 