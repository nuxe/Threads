import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppStore>
    
    var body: some View {
        Group {
            if store.isLoggedIn {
                mainAppView
            } else {
                AuthView(store: store.scope(state: \.authState, action: \.auth))
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(
            isPresented: Binding(
                get: { store.isShowingSettings },
                set: { _ in store.send(.hideSettings) }
            )
        ) {
            SettingsView(
                store: store.scope(state: \.settingsState, action: \.settings)
            ) {
                store.send(.hideSettings)
            }
        }
    }
    
    @ViewBuilder
    private var mainAppView: some View {
        if store.selectedThread != nil {
            // Chat view for selected thread
            if let chatStore = store.scope(state: \.chatState, action: \.chat) {
                ChatView(store: chatStore) {
                    store.send(.deselectThread)
                }
            }
        } else {
            // Thread list view
            ThreadListView(
                store: store.scope(state: \.threadListState, action: \.threadList),
                onThreadSelected: { thread in
                    store.send(.selectThread(thread))
                },
                onSettingsTapped: {
                    store.send(.showSettings)
                }
            )
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppStore.State()) {
        AppStore()
    })
} 
