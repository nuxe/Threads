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
        VStack(spacing: 16) {
            Image(systemName: "message.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No threads yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a new conversation to get going")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("New Thread") {
                store.send(.createNewThread)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
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

struct ThreadRowView: View {
    let thread: Thread
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastMessageAt = thread.lastMessageAt {
                        Text(lastMessageAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Tap to continue conversation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

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