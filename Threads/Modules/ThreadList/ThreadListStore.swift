import Foundation
import ComposableArchitecture

@Reducer
struct ThreadListStore {
    @ObservableState
    struct State: Equatable {
        var threads: [Thread] = []
        var isLoading = false
        var errorMessage: String?
        var searchText = ""
        var currentUser: User?
        
        var filteredThreads: [Thread] {
            if searchText.isEmpty {
                return threads.sorted { $0.lastMessageAt ?? $0.createdAt > $1.lastMessageAt ?? $1.createdAt }
            } else {
                return threads
                    .filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                    .sorted { $0.lastMessageAt ?? $0.createdAt > $1.lastMessageAt ?? $1.createdAt }
            }
        }
    }
    
    enum Action {
        case onAppear
        case loadThreads
        case createNewThread
        case deleteThread(UUID)
        case selectThread(Thread)
        case searchTextChanged(String)
        case setCurrentUser(User?)
        case refreshThreads
        
        // Internal actions
        case loadThreadsResponse(Result<[Thread], Error>)
        case createThreadResponse(Result<Thread, Error>)
        case deleteThreadResponse(Result<UUID, Error>)
    }
    
    @Dependency(\.supabaseClient) var supabaseClient
    @Dependency(\.openAIClient) var openAIClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadThreads)
                
            case .loadThreads:
                guard let userID = state.currentUser?.id else {
                    state.errorMessage = "No user logged in"
                    return .none
                }
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await send(.loadThreadsResponse(Result {
                        try await supabaseClient.getThreads(userID)
                    }))
                }
                
            case .createNewThread:
                guard let userID = state.currentUser?.id else {
                    state.errorMessage = "No user logged in"
                    return .none
                }
                let newThread = Thread(
                    title: "New Chat",
                    userID: userID
                )
                return .run { send in
                    await send(.createThreadResponse(Result {
                        try await supabaseClient.createThread(newThread)
                    }))
                }
                
            case let .deleteThread(threadID):
                return .run { send in
                    await send(.deleteThreadResponse(Result {
                        try await supabaseClient.deleteThread(threadID)
                        return threadID
                    }))
                }
                
            case .selectThread:
                // This will be handled by parent coordinator
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case let .setCurrentUser(user):
                state.currentUser = user
                return .none
                
            case .refreshThreads:
                return .send(.loadThreads)
                
            // Response actions
            case let .loadThreadsResponse(.success(threads)):
                state.isLoading = false
                state.threads = threads
                return .none
                
            case let .loadThreadsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .createThreadResponse(.success(thread)):
                state.threads.insert(thread, at: 0)
                return .none
                
            case let .createThreadResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .deleteThreadResponse(.success(threadID)):
                state.threads.removeAll { $0.id == threadID }
                return .none
                
            case let .deleteThreadResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
} 
