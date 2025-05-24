import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .opacity(isLoading ? 0.7 : 1.0)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
        LoadingView(message: "Processing...")
        LoadingButton(title: "Submit", isLoading: true, action: {})
        LoadingButton(title: "Submit", isLoading: false, action: {})
    }
} 