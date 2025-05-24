//
//  ContentView.swift
//  Threads
//
//  Created by Kush Agrawal on 5/23/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Threads")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Phase 1 Complete!")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("✅ Project structure created")
                Text("✅ Dependencies configured")
                Text("✅ TCA stores implemented")
                Text("✅ UI components created")
                Text("✅ Navigation setup")
            }
            .font(.subheadline)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Text("Ready for Phase 2: Core Chat Functionality")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.top)
        }
        .padding()
        .navigationTitle("Threads Development")
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
}
