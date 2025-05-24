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
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Actions Section
                Section("Actions") {
                    Button(action: {
                        store.send(.clearData)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.orange)
                            Text("Clear Local Data")
                                .foregroundColor(.primary)
                            Spacer()
                            if store.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(store.isLoading)
                    
                    Button(action: {
                        store.send(.signOut)
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                            if store.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(store.isLoading)
                }
                
                // App Info Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(store.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(store.buildNumber)
                            .foregroundColor(.secondary)
                    }
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