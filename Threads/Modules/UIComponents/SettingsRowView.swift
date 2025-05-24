import SwiftUI

struct SettingsRowView: View {
    let systemImage: String
    let title: String
    let subtitle: String?
    let value: String?
    let iconColor: Color
    let textColor: Color
    let action: (() -> Void)?
    let isLoading: Bool
    
    init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        iconColor: Color = .blue,
        textColor: Color = .primary,
        isLoading: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.iconColor = iconColor
        self.textColor = textColor
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                rowContent
            }
            .disabled(isLoading)
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(textColor)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
}

#Preview {
    List {
        Section("Account") {
            SettingsRowView(
                systemImage: "person.circle.fill",
                title: "User Profile",
                subtitle: "test@example.com"
            )
        }
        
        Section("Actions") {
            SettingsRowView(
                systemImage: "trash",
                title: "Clear Local Data",
                iconColor: .orange,
                action: {}
            )
            
            SettingsRowView(
                systemImage: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                iconColor: .red,
                textColor: .red,
                isLoading: true,
                action: {}
            )
        }
        
        Section("Info") {
            SettingsRowView(
                systemImage: "info.circle",
                title: "Version",
                value: "1.0.0"
            )
            
            SettingsRowView(
                systemImage: "hammer",
                title: "Build",
                value: "123"
            )
        }
    }
} 