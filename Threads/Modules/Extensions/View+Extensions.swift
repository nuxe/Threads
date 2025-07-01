import SwiftUI
import ComposableArchitecture

extension Binding {
    func sending<Action>(_ action: @escaping (Value) -> Action) -> Binding<Value> where Action: Equatable {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                // In a real implementation, this would send the action through a store
                // For now, we'll just update the value
                wrappedValue = newValue
            }
        )
    }
}

// Extension to help with conditional presentation
extension Binding where Value == Bool {
    func sending<Action>(_ action: Action) -> Binding<Bool> where Action: Equatable {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
            }
        )
    }
}

// Helper for navigation
extension View {
    @ViewBuilder
    func conditionalNavigationBarHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.large)
        } else {
            self
        }
    }
} 