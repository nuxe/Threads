import SwiftUI

struct AppLogoView: View {
    let subtitle: String?
    let size: CGFloat
    
    init(subtitle: String? = nil, size: CGFloat = 64) {
        self.subtitle = subtitle
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: size))
                .foregroundColor(.blue)
            
            Text("Threads")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AppLogoView(subtitle: "Welcome back")
        
        AppLogoView(subtitle: "Create your account")
        
        AppLogoView(size: 32)
        
        AppLogoView()
    }
    .padding()
} 