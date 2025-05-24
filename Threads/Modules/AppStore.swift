import Foundation
import ComposableArchitecture

@Reducer
struct AppStore {
    @ObservableState
    struct State: Equatable {
        var authState = AuthStore.State()
        var threadListState = ThreadListStore.State()
        var settingsState = SettingsStore.State()
        var chatState: ChatStore.State? = nil
        
        // Navigation
        var selectedThread: Thread?
        var isShowingSettings = false
        
        // Computed
        var isLoggedIn: Bool {
            authState.isLoggedIn
        }
    }
    
    enum Action {
        case auth(AuthStore.Action)
        case threadList(ThreadListStore.Action)
        case chat(ChatStore.Action)
        case settings(SettingsStore.Action)
        
        // Navigation actions
        case selectThread(Thread)
        case deselectThread
        case showSettings
        case hideSettings
        case onAppear
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.authState, action: \.auth) {
            AuthStore()
        }
        
        Scope(state: \.threadListState, action: \.threadList) {
            ThreadListStore()
        }
        
        Scope(state: \.settingsState, action: \.settings) {
            SettingsStore()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.auth(.checkAuthStatus))
                
            case .auth(.signOutResponse(.success)):
                state.selectedThread = nil
                state.chatState = nil
                state.isShowingSettings = false
                return .none
                
            case .auth(.authCheckResponse(.success(let user))):
                state.threadListState.currentUser = user
                state.settingsState.currentUser = user
                return .none
                
            case .auth(.signInResponse(.success(let user))),
                 .auth(.signUpResponse(.success(let user))):
                state.threadListState.currentUser = user
                state.settingsState.currentUser = user
                return .send(.threadList(.loadThreads))
                
            case .threadList(.selectThread(let thread)):
                return .send(.selectThread(thread))
                
            case let .selectThread(thread):
                state.selectedThread = thread
                state.chatState = ChatStore.State(thread: thread)
                return .none
                
            case .deselectThread:
                state.selectedThread = nil
                state.chatState = nil
                return .none
                
            case .chat(.goBack):
                return .send(.deselectThread)
                
            case .showSettings:
                state.isShowingSettings = true
                return .none
                
            case .hideSettings:
                state.isShowingSettings = false
                return .none
                
            case .settings(.signOutResponse(.success)):
                return .send(.auth(.signOut))
                
            case .threadList(.createThreadResponse(.success(let thread))):
                return .send(.selectThread(thread))
                
            // Pass through other actions
            case .auth, .threadList, .chat, .settings:
                return .none
            }
        }
        .ifLet(\.chatState, action: \.chat) {
            ChatStore()
        }
    }
} 
