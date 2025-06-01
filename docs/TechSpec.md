## Technical Overview

### Architecture Stack
- **UI Framework**: SwiftUI
- **Architecture**: The Composable Architecture (TCA)
- **Dependency Management**: Swift Package Manager
- **Backend**: Supabase (Auth + Database)
- **AI Integration**: OpenAI API via MacPaw/OpenAI package
- **Language Features**: Swift 5.9+ with async/await/throws

### Key Dependencies
```swift
// Package.swift dependencies
.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
.package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
.package(url: "https://github.com/MacPaw/OpenAI", from: "0.2.0")
```

### Folder Structure
```
Threads/
├── Package.swift
├── README.md
└── Modules/                # New features go here
    ├── Authentication/
    │   ├── AuthStore.swift
    │   └── AuthView.swift
    ├── ThreadList/
    │   ├── ThreadListStore.swift
    │   └── ThreadListView.swift
    ├── Chat/
    │   ├── ChatStore.swift
    │   └── ChatView.swift
    ├── Settings/
    │   ├── SettingsStore.swift
    │   └── SettingsView.swift
    ├── Models/             # New models go here
    │   ├── Thread.swift
    │   ├── Message.swift
    │   └── User.swift
    ├── Clients/            # New clients go here
    │   ├── OpenAIClient.swift
    │   ├── SupabaseClient.swift
    │   └── AuthClient.swift
    ├── Extensions/         # New extensions go here
    │   └── View+Extensions.swift
    └── UIComponents/       # Reusable UI components go here
        └── LoadingView.swift
```

## Key Technical Decisions

### Why TCA?
- Unidirectional data flow perfect for chat apps
- Excellent testing story with reducers
- Built-in dependency injection
- Great for managing complex async operations (API calls)

### Why Supabase?
- Built-in authentication with social providers
- Real-time subscriptions for live updates
- PostgreSQL with full SQL capabilities
- Row Level Security for data protection
- Generous free tier

### Why MacPaw/OpenAI?
- Well-maintained Swift OpenAI client
- Supports streaming responses
- Type-safe API interactions
- Active community and updates
