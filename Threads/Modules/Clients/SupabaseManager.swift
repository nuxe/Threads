import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // Replace these with your actual Supabase project credentials
    private let supabaseURL = "YOUR_SUPABASE_URL"
    private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    let client: SupabaseClient
    
    private init() {
        guard !supabaseURL.contains("YOUR_"),
              !supabaseAnonKey.contains("YOUR_") else {
            fatalError("Please configure your Supabase credentials in SupabaseManager.swift")
        }
        
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
    }
} 