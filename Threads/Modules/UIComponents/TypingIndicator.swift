import SwiftUI

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .onAppear {
            animationOffset = -4
        }
        .onDisappear {
            animationOffset = 0
        }
    }
}

struct AITypingIndicator: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // AI avatar placeholder
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "cpu")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI is typing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TypingIndicator()
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

#Preview {
    VStack(spacing: 20) {
        TypingIndicator()
        AITypingIndicator()
    }
    .padding()
}