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
