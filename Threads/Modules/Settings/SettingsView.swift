import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsStore>
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                // User Section
                if let user = store.currentUser {
                    Section("Account") {
                        SettingsRowView(
                            systemImage: "person.circle.fill",
                            title: user.displayName ?? "User",
                            subtitle: user.email
                        )
                    }
                }
                
                // Actions Section
                Section("Actions") {
                    SettingsRowView(
                        systemImage: "trash",
                        title: "Clear Local Data",
                        iconColor: .orange,
                        isLoading: store.isLoading
                    ) {
                        store.send(.clearData)
                    }
                    
                    SettingsRowView(
                        systemImage: "rectangle.portrait.and.arrow.right",
                        title: "Sign Out",
                        iconColor: .red,
                        textColor: .red,
                        isLoading: store.isLoading
                    ) {
                        store.send(.signOut)
                    }
                }
                
                // App Info Section
                Section("App Information") {
                    SettingsRowView(
                        systemImage: "info.circle",
                        title: "Version",
                        value: store.appVersion
                    )
                    
                    SettingsRowView(
                        systemImage: "hammer",
                        title: "Build",
                        value: store.buildNumber
                    )
                }
                
                // About Section
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Threads")
                            .font(.headline)
                        
                        Text("A modern AI chat application built with SwiftUI and The Composable Architecture.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            .alert(
                "Error",
                isPresented: .constant(store.errorMessage != nil),
                actions: {
                    Button("OK") {
                        store.send(.dismissError)
                    }
                },
                message: {
                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                    }
                }
            )
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SettingsView(
        store: Store(initialState: SettingsStore.State(
            currentUser: User(email: "test@example.com", displayName: "Test User")
        )) {
            SettingsStore()
        },
        onDismiss: {}
    )
} 