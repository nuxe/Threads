import SwiftUI

struct ErrorMessageView: View {
    let message: String
    let style: ErrorStyle
    
    enum ErrorStyle {
        case inline
        case banner
        case alert
    }
    
    init(_ message: String, style: ErrorStyle = .inline) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .inline:
            inlineErrorView
        case .banner:
            bannerErrorView
        case .alert:
            alertErrorView
        }
    }
    
    private var inlineErrorView: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.caption)
            .padding(.horizontal)
    }
    
    private var bannerErrorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .foregroundColor(.red)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var alertErrorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorMessageView("Invalid email address")
        
        ErrorMessageView("Network connection failed", style: .banner)
        
        ErrorMessageView("Something went wrong. Please try again.", style: .alert)
    }
    .padding()
} 