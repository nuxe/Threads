import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    // MARK: - OpenAI Configuration
    
    var openAIAPIKey: String? {
        // First check environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return envKey
        }
        
        // Then check UserDefaults (for app settings)
        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            return savedKey
        }
        
        return nil
    }
    
    func setOpenAIAPIKey(_ key: String?) {
        if let key = key {
            UserDefaults.standard.set(key, forKey: "openai_api_key")
        } else {
            UserDefaults.standard.removeObject(forKey: "openai_api_key")
        }
    }
    
    // MARK: - Validation
    
    var isOpenAIConfigured: Bool {
        openAIAPIKey != nil && !openAIAPIKey!.isEmpty
    }
    
    var isSupabaseConfigured: Bool {
        let manager = SupabaseManager.shared
        return !manager.client.supabaseURL.absoluteString.contains("YOUR_")
    }
    
    var isFullyConfigured: Bool {
        isOpenAIConfigured && isSupabaseConfigured
    }
} 