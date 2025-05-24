import SwiftUI
import ComposableArchitecture

struct ThreadListView: View {
    @Bindable var store: StoreOf<ThreadListStore>
    let onThreadSelected: (Thread) -> Void
    let onSettingsTapped: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if store.isLoading && store.threads.isEmpty {
                    LoadingView(message: "Loading threads...")
                } else if store.threads.isEmpty {
                    emptyStateView
                } else {
                    threadListView
                }
            }
            .navigationTitle("Threads")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onSettingsTapped()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.createNewThread)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $store.searchText.sending(\.searchTextChanged))
            .refreshable {
                store.send(.refreshThreads)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            systemImage: "message.circle",
            title: "No threads yet",
            message: "Start a new conversation to get going",
            buttonTitle: "New Thread"
        ) {
            store.send(.createNewThread)
        }
    }
    
    private var threadListView: some View {
        List {
            ForEach(store.filteredThreads) { thread in
                ThreadRowView(thread: thread) {
                    onThreadSelected(thread)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Delete", role: .destructive) {
                        store.send(.deleteThread(thread.id))
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// ThreadRowView is now in UIComponents

#Preview {
    ThreadListView(
        store: Store(initialState: ThreadListStore.State(
            threads: [
                Thread(title: "Swift Development Help", userID: UUID()),
                Thread(title: "Recipe Ideas", userID: UUID()),
                Thread(title: "Travel Planning", userID: UUID())
            ]
        )) {
            ThreadListStore()
        },
        onThreadSelected: { _ in },
        onSettingsTapped: {}
    )
} 