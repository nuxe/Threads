import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let buttonTitle: String?
    let onButtonTap: (() -> Void)?
    
    init(
        systemImage: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        onButtonTap: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onButtonTap = onButtonTap
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let onButtonTap = onButtonTap {
                Button(buttonTitle) {
                    onButtonTap()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 50) {
        // With button
        EmptyStateView(
            systemImage: "message.circle",
            title: "No threads yet",
            message: "Start a new conversation to get going",
            buttonTitle: "New Thread",
            onButtonTap: {}
        )
        
        // Without button
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No results found",
            message: "Try adjusting your search criteria"
        )
    }
} 