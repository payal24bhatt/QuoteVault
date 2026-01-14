//
//  QuoteVaultWidgetLiveActivity.swift
//  QuoteVaultWidget
//
//  Created by Payal Bhatt on 13/01/26.
//
//  NOTE: Live Activities are not required for the basic widget functionality.
//  This file is kept for future use but is not included in the widget bundle.

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
struct QuoteVaultWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var emoji: String
    }
    var name: String
}

@available(iOS 16.2, *)
struct QuoteVaultWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuoteVaultWidgetAttributes.self) { context in
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text(context.state.emoji)
            }
        }
    }
}
