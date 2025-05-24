import SwiftUI
import ComposableArchitecture

struct ChatView: View {
    @Bindable var store: StoreOf<ChatStore>
    let onBackTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            if store.isLoading && store.messages.isEmpty {
                LoadingView(message: "Loading messages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.messages) { message in
                                MessageBubble(message: message) {
                                    store.send(.deleteMessage(message.id))
                                }
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: store.messages.count) { _, _ in
                        if let lastMessage = store.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Message input
            MessageInputView(
                text: $store.messageText.sending(\.messageTextChanged),
                isDisabled: store.isStreaming,
                onSend: {
                    store.send(.sendMessage)
                }
            )
        }
        .navigationTitle(store.thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBackTapped()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Threads")
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MessageBubble and MessageInputView are now in UIComponents

#Preview {
    NavigationView {
        ChatView(
            store: Store(initialState: ChatStore.State(
                thread: Thread(title: "Test Chat", userID: UUID())
            )) {
                ChatStore()
            },
            onBackTapped: {}
        )
    }
} 