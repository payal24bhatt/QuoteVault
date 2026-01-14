# Widget Setup Guide

## How the Widget Works

The QuoteVault widget displays the **Quote of the Day** on the iOS home screen and updates daily. When users tap the widget, it opens the app to the home screen showing the quote.

### Features Implemented:
✅ Home screen widget displaying current quote of the day  
✅ Widget updates daily (at midnight)  
✅ Tapping widget opens the app via deep linking  

## Setup Instructions

### Step 1: Share Code Between App and Widget Extension

The widget extension needs access to shared code. In Xcode:

1. **Select these files** in the Project Navigator:
   - `QuoteVault/Services/QuoteRepository.swift`
   - `QuoteVault/Services/SupabaseService.swift`
   - `QuoteVault/Module/Home/Model/QuoteModel.swift`

2. **Open File Inspector** (right panel, first tab)

3. **Under "Target Membership"**, check:
   - ✅ QuoteVault (main app)
   - ✅ QuoteVaultWidgetExtension (widget extension)

This allows the widget to use the same Supabase client and models as the main app.

### Step 2: Verify Widget Extension Target

1. In Xcode, go to **Product → Scheme → Manage Schemes**
2. Ensure **QuoteVaultWidgetExtension** scheme exists
3. Select it and click **Run** to test the widget

### Step 3: Add Widget to Home Screen

1. Run the app on a device or simulator
2. Long-press on the home screen
3. Tap the **+** button in the top-left
4. Search for "QuoteVault"
5. Select **Quote of the Day** widget
6. Choose size (Small or Medium)
7. Tap **Add Widget**

## How It Works Technically

### 1. Widget Timeline Provider (`QuoteProvider`)
- Fetches quote of the day from Supabase using `QuoteRepository.shared.fetchQuoteOfTheDay()`
- Updates the timeline once per day at midnight
- Falls back to a default quote if fetch fails

### 2. Widget View (`QuoteVaultWidgetEntryView`)
- Displays the quote text and author
- Shows "Quote of the Day" header
- Supports Small and Medium widget sizes

### 3. Deep Linking
- Widget uses URL scheme: `quotevault://quoteoftheday`
- When tapped, `SceneDelegate.handleWidgetURL()` is called
- App navigates to home screen (which shows quote of the day)

### 4. Daily Updates
- Timeline policy set to `.after(tomorrow)` - updates at midnight
- iOS automatically refreshes the widget based on the timeline

## Testing

1. **Test Widget Display:**
   - Add widget to home screen
   - Verify quote is displayed correctly
   - Check both Small and Medium sizes

2. **Test Daily Update:**
   - Manually trigger timeline refresh in Xcode
   - Or wait until next day to see automatic update

3. **Test Deep Linking:**
   - Tap the widget
   - Verify app opens to home screen
   - Check that quote of the day is visible

## Troubleshooting

### Widget shows "No data" or default quote:
- Check that `QuoteRepository`, `SupabaseService`, and `QuoteModel` are added to widget target
- Verify Supabase connection is working
- Check console logs for errors

### Widget doesn't update:
- Widgets update based on iOS system schedule
- Force refresh: Long-press widget → "Edit Widget" → Remove and re-add
- Or wait for iOS to refresh (usually within 15 minutes)

### Deep linking doesn't work:
- Verify URL scheme is in `Info.plist` (already added)
- Check that `SceneDelegate.handleWidgetURL()` is called
- Test URL manually: `quotevault://quoteoftheday`

## Notes

- Widget extension runs in a separate process from the main app
- Widget has limited memory and execution time
- Network calls should be quick (< 5 seconds)
- Widget updates are managed by iOS, not guaranteed to be instant

