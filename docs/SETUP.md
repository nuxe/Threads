# Threads App Setup Guide

## Prerequisites

- Xcode 15.0 or later
- macOS 14.0 or later
- A Supabase account (free tier works)
- An OpenAI API account

## Step 1: Supabase Setup

### 1.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create an account
2. Create a new project
3. Save your project URL and anon key

### 1.2 Set up the Database

1. Go to the SQL Editor in your Supabase dashboard
2. Copy and run all the SQL commands from `Database.md` in order:
   - Create tables (profiles, threads, messages)
   - Enable Row Level Security
   - Create indexes
   - Create functions and triggers

### 1.3 Configure Authentication

1. Go to Authentication → Settings
2. Enable Email authentication
3. (Optional) Enable social providers like Google, GitHub, etc.

## Step 2: OpenAI Setup

1. Go to [platform.openai.com](https://platform.openai.com)
2. Create an API key
3. Save it securely - you'll need it later

## Step 3: Configure the App

### 3.1 Update Supabase Credentials

Open `Threads/Modules/Clients/SupabaseManager.swift` and replace:

```swift
private let supabaseURL = "YOUR_SUPABASE_URL"
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
```

With your actual Supabase project credentials.

### 3.2 Set OpenAI API Key

You have two options:

#### Option A: Environment Variable (Recommended for Development)

1. In Xcode, go to Product → Scheme → Edit Scheme
2. Select Run → Arguments
3. Add an environment variable:
   - Name: `OPENAI_API_KEY`
   - Value: Your OpenAI API key

#### Option B: In-App Configuration

The app will save the API key in UserDefaults after the first successful configuration.

## Step 4: Build and Run

1. Open `Threads.xcodeproj` in Xcode
2. Select your target device (simulator or physical device)
3. Press Cmd+R to build and run

## Step 5: First Run

1. Create an account using the sign-up form
2. Start a new conversation
3. Send your first message!

## Troubleshooting

### "Please configure your Supabase credentials"

- Make sure you've updated `SupabaseManager.swift` with your credentials
- Check that the URL starts with `https://` and ends with `.supabase.co`

### "OpenAI API key not configured"

- Make sure you've set the `OPENAI_API_KEY` environment variable
- Verify the API key is valid and has credits

### Authentication errors

- Check your Supabase dashboard to ensure authentication is enabled
- Verify your database schema was created correctly
- Check the Supabase logs for any errors

### Database errors

- Ensure all tables were created with the correct schema
- Verify Row Level Security policies are in place
- Check that triggers and functions were created

## Security Notes

- Never commit your API keys to version control
- Use environment variables for sensitive data
- Consider using a `.env` file with a tool like [SwiftDotEnv](https://github.com/thebarndog/swift-dotenv) for production

## Next Steps

- Customize the UI to match your brand
- Add additional features like image support
- Implement offline caching
- Add push notifications for async responses 