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

### Data Models

#### Thread Model
```swift
struct Thread: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let userId: UUID
}
```

#### Message Model
```swift
struct Message: Codable, Identifiable, Equatable {
    let id: UUID
    let threadId: UUID
    let content: String
    let role: MessageRole // user or assistant
    let createdAt: Date
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
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

## Technical Roadmap

### Phase 1: Foundation Setup
- [ ] Create new iOS project with SwiftUI + TCA
- [ ] Add SPM dependencies (TCA, Supabase, OpenAI)
- [ ] Set up basic app structure and navigation
- [ ] Configure Supabase project and database schema
- [ ] Implement basic data models and TCA features

### Phase 2: Authentication
- [ ] Create Supabase auth client
- [ ] Implement AuthFeature with login/signup actions
- [ ] Build authentication UI screens
- [ ] Add session persistence and automatic login
- [ ] Handle auth state changes throughout app

### Phase 3: Core Chat Functionality
- [ ] Implement OpenAI client wrapper
- [ ] Create ChatFeature with message sending/receiving
- [ ] Build chat UI with message bubbles and input field
- [ ] Add typing indicators and loading states
- [ ] Implement real-time message streaming

### Phase 4: Thread Management
- [ ] Create ThreadListFeature for managing conversations
- [ ] Implement thread CRUD operations with Supabase
- [ ] Build thread list UI with swipe actions
- [ ] Add thread search and filtering
- [ ] Implement thread title auto-generation

### Phase 5: Data Persistence
- [ ] Set up Supabase database schema (threads, messages)
- [ ] Implement repository pattern for data access
- [ ] Add offline caching with local Core Data/SQLite
- [ ] Sync local and remote data
- [ ] Handle network connectivity states

### Phase 6: Polish & Features
- [ ] Add message copying and sharing
- [ ] Implement dark/light theme support
- [ ] Add haptic feedback and animations
- [ ] Optimize performance for large conversation histories
- [ ] Add settings screen for user preferences

### Phase 7: Testing & Deployment
- [ ] Unit tests for TCA reducers and effects
- [ ] Integration tests for API clients
- [ ] UI tests for critical user flows
- [ ] TestFlight beta testing
- [ ] App Store submission

## Database Schema (Supabase)

### Tables
```sql
-- Users table (handled by Supabase Auth)
-- No custom user table needed

-- Threads table
CREATE TABLE threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id UUID REFERENCES threads(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_threads_user_id ON threads(user_id);
CREATE INDEX idx_threads_updated_at ON threads(updated_at DESC);
CREATE INDEX idx_messages_thread_id ON messages(thread_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

### Row Level Security (RLS)
```sql
-- Enable RLS on tables
ALTER TABLE threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Threads policies
CREATE POLICY "Users can view own threads" ON threads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own threads" ON threads FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own threads" ON threads FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own threads" ON threads FOR DELETE USING (auth.uid() = user_id);

-- Messages policies  
CREATE POLICY "Users can view messages in own threads" ON messages FOR SELECT 
USING (EXISTS (SELECT 1 FROM threads WHERE threads.id = messages.thread_id AND threads.user_id = auth.uid()));

CREATE POLICY "Users can insert messages in own threads" ON messages FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM threads WHERE threads.id = messages.thread_id AND threads.user_id = auth.uid()));
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

This roadmap provides a solid foundation for building a production-ready ChatGPT clone while leveraging modern Swift development practices and proven architectural patterns.