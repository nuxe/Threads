import Foundation
import ComposableArchitecture

@Reducer
struct AuthStore {
    @ObservableState
    struct State: Equatable {
        var isLoggedIn = false
        var currentUser: User?
        var isLoading = false
        var errorMessage: String?
        
        // Sign In/Up form state
        var email = ""
        var password = ""
        var isSignUpMode = false
    }
    
    enum Action {
        case checkAuthStatus
        case signIn
        case signUp
        case signOut
        case toggleSignUpMode
        case emailChanged(String)
        case passwordChanged(String)
        case clearError
        
        // Internal actions
        case authCheckResponse(Result<User?, Error>)
        case signInResponse(Result<User, Error>)
        case signUpResponse(Result<User, Error>)
        case signOutResponse(Result<Void, Error>)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .checkAuthStatus:
                state.isLoading = true
                return .run { send in
                    await send(.authCheckResponse(Result {
                        try await authClient.getCurrentUser()
                    }))
                }
                
            case .signIn:
                guard !state.email.isEmpty, !state.password.isEmpty else {
                    state.errorMessage = "Please enter email and password"
                    return .none
                }
                state.isLoading = true
                state.errorMessage = nil
                return .run { [email = state.email, password = state.password] send in
                    await send(.signInResponse(Result {
                        try await authClient.signIn(email, password)
                    }))
                }
                
            case .signUp:
                guard !state.email.isEmpty, !state.password.isEmpty else {
                    state.errorMessage = "Please enter email and password"
                    return .none
                }
                state.isLoading = true
                state.errorMessage = nil
                return .run { [email = state.email, password = state.password] send in
                    await send(.signUpResponse(Result {
                        try await authClient.signUp(email, password)
                    }))
                }
                
            case .signOut:
                state.isLoading = true
                return .run { send in
                    await send(.signOutResponse(Result {
                        try await authClient.signOut()
                    }))
                }
                
            case .toggleSignUpMode:
                state.isSignUpMode.toggle()
                state.errorMessage = nil
                return .none
                
            case let .emailChanged(email):
                state.email = email
                state.errorMessage = nil
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                state.errorMessage = nil
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
                
            // Response actions
            case let .authCheckResponse(.success(user)):
                state.isLoading = false
                state.currentUser = user
                state.isLoggedIn = user != nil
                return .none
                
            case let .authCheckResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .signInResponse(.success(user)):
                state.isLoading = false
                state.currentUser = user
                state.isLoggedIn = true
                state.email = ""
                state.password = ""
                return .none
                
            case let .signInResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .signUpResponse(.success(user)):
                state.isLoading = false
                state.currentUser = user
                state.isLoggedIn = true
                state.email = ""
                state.password = ""
                return .none
                
            case let .signUpResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .signOutResponse(.success):
                state.isLoading = false
                state.currentUser = nil
                state.isLoggedIn = false
                state.email = ""
                state.password = ""
                return .none
                
            case let .signOutResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
} 
