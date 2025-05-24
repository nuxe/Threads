import Foundation
import ComposableArchitecture

@Reducer
struct SettingsStore {
    @ObservableState
    struct State: Equatable {
        var currentUser: User?
        var isLoading = false
        var errorMessage: String?
        
        // Settings
        var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        var buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    enum Action {
        case onAppear
        case signOut
        case clearData
        case setCurrentUser(User?)
        case dismissError
        
        // Internal actions
        case signOutResponse(TaskResult<Void>)
        case clearDataResponse(TaskResult<Void>)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .signOut:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await send(.signOutResponse(TaskResult {
                        try await authClient.signOut()
                    }))
                }
                
            case .clearData:
                // TODO: Implement data clearing functionality
                state.isLoading = true
                return .run { send in
                    await send(.clearDataResponse(TaskResult {
                        // Clear local data, cache, etc.
                        // This would be implemented in Phase 5
                    }))
                }
                
            case let .setCurrentUser(user):
                state.currentUser = user
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
                
            // Response actions
            case .signOutResponse(.success):
                state.isLoading = false
                state.currentUser = nil
                return .none
                
            case let .signOutResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .clearDataResponse(.success):
                state.isLoading = false
                return .none
                
            case let .clearDataResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
} 
