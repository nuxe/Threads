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

struct MessageBubble: View {
    let message: Message
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.role == .user ? Color.blue : Color(.systemGray5))
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .overlay(
                        Group {
                            if message.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .scaleEffect(0.7)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .onLongPressGesture {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    onDelete()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(alert, animated: true)
                }
            }
            
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
    }
}

struct MessageInputView: View {
    @Binding var text: String
    let isDisabled: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...6)
                .disabled(isDisabled)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled ? .gray : .blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled)
        }
        .padding()
    }
}

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