# QuoteVault 📚

A full-featured iOS quote discovery and collection app built with UIKit, Supabase, and WidgetKit. Discover inspiring quotes, organize them into collections, and get daily inspiration through notifications and widgets.

## ✨ Features

### ✅ Authentication & User Accounts
- Sign up with email/password
- Login/logout functionality
- Password reset flow with email verification
- User profile screen with avatar upload
- Session persistence (stay logged in)

### ✅ Quote Browsing & Discovery
- Home feed displaying quotes with pagination
- Browse quotes by category (Motivation, Love, Success, Wisdom, Humor)
- Search quotes by keyword (searches both quote text and author)
- Filter by category
- Pull-to-refresh functionality
- Loading states and empty states handled gracefully
- Quote of the Day prominently displayed

### ✅ Favorites & Collections
- Save quotes to favorites (heart icon)
- View all favorited quotes in a dedicated screen
- Create custom collections (e.g., "Morning Motivation", "Work Quotes")
- Add/remove quotes from collections
- Cloud sync — favorites and collections persist across devices

### ✅ Daily Quote & Notifications
- "Quote of the Day" prominently displayed on home screen
- Quote of the day changes daily (based on day of year)
- Local push notification for daily quote
- User can set preferred notification time in settings
- Notifications include the actual quote text

### ✅ Sharing & Export
- Share quote as text via system share sheet
- Generate shareable quote card (quote + author on styled background)
- Save quote card as image to device photo library
- 3 different card styles: Minimal, Gradient, Elegant

### ✅ Personalization & Settings
- Dark mode / Light mode toggle
- System theme (follows device setting)
- 5 accent colors to choose from (Blue, Purple, Teal, Orange, Pink)
- Font size adjustment for quotes (14pt - 22pt)
- Settings persist locally and sync to user profile

### ✅ Widget
- Home screen widget displaying current quote of the day
- Widget updates daily
- Tapping widget opens the app to that quote
- Supports iOS 16+ with proper container background API

## 🛠️ Tech Stack

- **Framework**: UIKit (iOS 16+)
- **Backend**: Supabase (Auth + Database + Storage)
- **Widget**: WidgetKit (SwiftUI)
- **Language**: Swift 5.9+
- **Architecture**: MVVM (where applicable) + MVC
- **Dependencies**:
  - Supabase Swift SDK (2.5.1+)
  - IQKeyboardManager
  - Kingfisher (for image loading)

## 📋 Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- macOS 13.0+ (for development)
- Supabase account (free tier works)
- CocoaPods or Swift Package Manager (SPM)

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/QuoteVault.git
cd QuoteVault
```

### 2. Supabase Setup

#### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your project URL and anon key from Settings → API

#### Database Schema

Create the following tables in your Supabase database:

**1. `profiles` table:**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all profiles, update their own
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
```

**2. `categories` table:**
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous read access (for widget)
CREATE POLICY "Anyone can read categories" ON categories FOR SELECT USING (true);
```

**3. `quotes` table:**
```sql
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category_id UUID REFERENCES categories(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous read access (for widget and browsing)
CREATE POLICY "Anyone can read quotes" ON quotes FOR SELECT USING (true);
```

**4. `user_favorites` table:**
```sql
CREATE TABLE user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Enable RLS
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only manage their own favorites
CREATE POLICY "Users can view own favorites" ON user_favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON user_favorites FOR DELETE USING (auth.uid() = user_id);
```

**5. `collections` table:**
```sql
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only manage their own collections
CREATE POLICY "Users can view own collections" ON collections FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own collections" ON collections FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own collections" ON collections FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own collections" ON collections FOR DELETE USING (auth.uid() = user_id);
```

**6. `collection_quotes` table:**
```sql
CREATE TABLE collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

-- Enable RLS
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage quotes in their own collections
CREATE POLICY "Users can manage own collection quotes" ON collection_quotes 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM collections 
      WHERE collections.id = collection_quotes.collection_id 
      AND collections.user_id = auth.uid()
    )
  );
```

**7. `user_settings` table:**
```sql
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT DEFAULT 'system',
  font_size INTEGER DEFAULT 16,
  accent_color TEXT DEFAULT 'blue',
  notification_enabled BOOLEAN DEFAULT false,
  notification_time TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only manage their own settings
CREATE POLICY "Users can manage own settings" ON user_settings 
  FOR ALL USING (auth.uid() = user_id);
```

#### Seed the Database

1. **Add Categories:**
```sql
INSERT INTO categories (name) VALUES 
  ('Motivation'),
  ('Love'),
  ('Success'),
  ('Wisdom'),
  ('Humor');
```

2. **Add Quotes (100+ recommended):**
   - You can use the Supabase SQL Editor or import from a CSV
   - Ensure each quote has a valid `category_id` referencing one of the categories above
   - Example:
```sql
INSERT INTO quotes (text, author, category_id) VALUES 
  ('The only way to do great work is to love what you do.', 'Steve Jobs', 
   (SELECT id FROM categories WHERE name = 'Success' LIMIT 1)),
  ('Life is what happens to you while you''re busy making other plans.', 'John Lennon',
   (SELECT id FROM categories WHERE name = 'Wisdom' LIMIT 1));
```

#### Storage Setup

1. **Create `avatars` bucket:**
   - Go to Storage in Supabase dashboard
   - Create a new bucket named `avatars`
   - Set it to **Public**
   - Add policy: Allow authenticated users to upload/update their own files

```sql
-- Storage policy for avatars bucket
CREATE POLICY "Users can upload own avatar" ON storage.objects 
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own avatar" ON storage.objects 
  FOR UPDATE USING (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can view avatars" ON storage.objects 
  FOR SELECT USING (bucket_id = 'avatars');
```

#### Configure Authentication

1. **Email Auth:**
   - Go to Authentication → Providers
   - Enable Email provider
   - Configure email templates if needed

2. **Redirect URLs:**
   - Go to Authentication → URL Configuration
   - Add redirect URL: `quotevault://reset-password`
   - This is required for password reset functionality

### 3. Configure the App

1. **Update Supabase Credentials:**
   - Open `QuoteVault/Services/SupabaseService.swift`
   - Update `SupabaseConfig` with your project details:
   ```swift
   enum SupabaseConfig {
       static let url = "https://your-project.supabase.co"
       static let anonKey = "your-anon-key"
   }
   ```

2. **Open the Project:**
   ```bash
   open QuoteVault.xcodeproj
   ```

3. **Install Dependencies:**
   - Dependencies are managed via Swift Package Manager
   - Xcode should automatically resolve packages on first build
   - If not, go to File → Packages → Resolve Package Versions

4. **Configure Signing:**
   - Select the `QuoteVault` target
   - Go to Signing & Capabilities
   - Select your development team
   - Xcode will automatically manage provisioning profiles

5. **Build and Run:**
   - Select a simulator or connected device
   - Press `Cmd + R` to build and run

### 4. Widget Setup

The widget extension is already configured. To test:

1. Build and run the app on a device (widgets don't work well in simulator)
2. Long press on home screen → Add Widget → QuoteVault
3. Select "Quote of the Day" widget
4. The widget will display today's quote and update daily

## 📱 App Structure

```
QuoteVault/
├── App/                    # App lifecycle (AppDelegate, SceneDelegate)
├── Module/                 # Feature modules
│   ├── Home/              # Home feed with quotes
│   ├── Login/             # Authentication
│   ├── Signup/            # User registration
│   ├── Favorites/         # Favorite quotes
│   ├── Collections/       # Custom collections
│   ├── Setting/           # Settings & Profile
│   ├── Splash/            # Splash screen
│   └── Tabbar/            # Tab bar controller
├── Services/              # Business logic
│   ├── SupabaseService    # Supabase client
│   ├── QuoteRepository    # Data access layer
│   ├── NotificationService # Local notifications
│   └── QuoteCardGenerator # Image generation
├── Core/                  # Core utilities
│   ├── Constant/          # Constants, ThemeManager, SettingsManager
│   ├── Extensions/        # UIKit & Foundation extensions
│   └── Utilities/         # Helper utilities
├── Model/                 # Data models
└── QuoteVaultWidget/      # Widget extension
```

## 🤖 AI Tools Used

This project was built using AI-assisted development with the following tools:

- Cursor AI (primary development environment)
- Claude (via Cursor) — reasoning, debugging, refactoring
- GitHub Copilot — code completion

AI was used for:
- Swift & iOS development guidance
- Supabase integration and RLS policies
- WidgetKit implementation
- Debugging runtime and edge-case issues
- Architectural decisions (MVVM/MVC)

## 🎨 Design

- **Design Tool**: Figma
- **Approach**:
  - Screens were designed in Figma before implementation
  - Focus on clean, minimal, and readable UI
  - Consistent spacing, typography, and color usage
  - Dark mode–first design with accessibility in mind

### Designed Screens
- Login / Signup / Reset Password
- Home (Quotes feed & filters)
- Favorites & Collections
- Profile & Settings
- Quote of the Day Widget

🔗 **Figma Design Link:**  
👉https://www.figma.com/design/14EzIdI7naiMahos0FQGGu/QuoteVault-%E2%80%93-UI-Designs?node-id=0-1&p=f&t=5NHVwKMm4Vot7BnQ-0


## ⚠️ Known Limitations

1. **Widget**: 
   - Requires device testing (limited simulator support)
   - Widget may show placeholder if quotes table is empty
   - RLS policies must allow anonymous read access for widget

2. **Notifications**:
   - Requires user permission (requested on first use)
   - Background fetch for quote updates is limited

3. **Avatar Upload**:
   - Requires `avatars` bucket to be created in Supabase Storage
   - Bucket must be set to public with proper RLS policies

4. **Password Reset**:
   - Requires redirect URL to be configured in Supabase dashboard
   - Email link expires after 1 hour

5. **Search**:
   - Currently searches both quote text and author with same term
   - No advanced search filters (date, category combination)

## 🐛 Troubleshooting

### App crashes on launch
- Check Supabase credentials in `SupabaseService.swift`
- Verify network connectivity
- Check console logs for specific errors

### Widget not showing quotes
- Verify RLS policies allow anonymous read access
- Check that quotes table has data
- Ensure widget extension target includes Supabase dependency

### Photos not saving
- Check that `NSPhotoLibraryAddUsageDescription` is in Info.plist
- Verify photo library permission is granted in Settings

### Password reset not working
- Verify redirect URL is set in Supabase dashboard: `quotevault://reset-password`
- Check that email provider is enabled in Supabase

### Categories not loading
- Check RLS policies for `categories` table
- Verify categories table has data
- Check console logs for decoding errors

## 📝 Database Seeding

To seed your database with sample quotes, you can:

1. Use Supabase SQL Editor to run INSERT statements
2. Import from CSV using Supabase dashboard
3. Use a script to generate quotes programmatically

Example seeding script structure:
```sql
-- Get category IDs first
DO $$
DECLARE
  motivation_id UUID;
  love_id UUID;
  success_id UUID;
  wisdom_id UUID;
  humor_id UUID;
BEGIN
  SELECT id INTO motivation_id FROM categories WHERE name = 'Motivation' LIMIT 1;
  SELECT id INTO love_id FROM categories WHERE name = 'Love' LIMIT 1;
  SELECT id INTO success_id FROM categories WHERE name = 'Success' LIMIT 1;
  SELECT id INTO wisdom_id FROM categories WHERE name = 'Wisdom' LIMIT 1;
  SELECT id INTO humor_id FROM categories WHERE name = 'Humor' LIMIT 1;
  
  -- Insert quotes (repeat for 100+ quotes)
  INSERT INTO quotes (text, author, category_id) VALUES 
    ('Quote text here', 'Author name', motivation_id),
    -- ... more quotes
END $$;
```

## 🧪 Testing

### Manual Testing Checklist

- [ ] Sign up with new account
- [ ] Login with existing account
- [ ] Password reset flow
- [ ] Browse quotes with pagination
- [ ] Search quotes by text and author
- [ ] Filter by category
- [ ] Add/remove favorites
- [ ] Create collections
- [ ] Add quotes to collections
- [ ] Share quote as text
- [ ] Generate and save quote cards
- [ ] Change theme (light/dark/system)
- [ ] Adjust font size
- [ ] Change accent color
- [ ] Enable/disable notifications
- [ ] Set notification time
- [ ] Upload profile avatar
- [ ] Edit profile name
- [ ] Widget displays quote
- [ ] Widget opens app on tap

### TestFlight Build
A TestFlight build is not provided as it requires a paid Apple Developer account.
The app can be run directly via Xcode on a simulator or physical device.

## 📄 License

This project is created for demonstration purposes.

## 👤 Author

Built as part of a Mobile Application Developer assignment demonstrating AI-assisted development.

## 🙏 Acknowledgments

- Supabase for backend infrastructure
- Apple for UIKit and WidgetKit frameworks
- Open source community for inspiration and tools

---

**Note**: This README is part of the assignment submission. For questions or issues, please refer to the project repository or contact the developer.

