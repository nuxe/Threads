import SwiftUI
import ComposableArchitecture

struct AuthView: View {
    @Bindable var store: StoreOf<AuthStore>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("Threads")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(store.isSignUpMode ? "Create your account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $store.email.sending(\.emailChanged))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $store.password.sending(\.passwordChanged))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    LoadingButton(
                        title: store.isSignUpMode ? "Sign Up" : "Sign In",
                        isLoading: store.isLoading
                    ) {
                        if store.isSignUpMode {
                            store.send(.signUp)
                        } else {
                            store.send(.signIn)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                
                // Toggle between sign in/up
                Button {
                    store.send(.toggleSignUpMode)
                } label: {
                    Text(store.isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .conditionalNavigationBarHidden(true)
        }
        .onAppear {
            store.send(.checkAuthStatus)
        }
    }
}

#Preview {
    AuthView(store: Store(initialState: AuthStore.State()) {
        AuthStore()
    })
} 