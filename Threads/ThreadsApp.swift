//
//  ThreadsApp.swift
//  Threads
//
//  Created by Kush Agrawal on 5/23/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct ThreadsApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppStore.State()) {
                AppStore()
            })
        }
    }
}
