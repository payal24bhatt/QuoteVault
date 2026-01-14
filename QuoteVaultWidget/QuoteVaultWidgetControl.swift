//
//  QuoteVaultWidgetControl.swift
//  QuoteVaultWidget
//
//  Created by Payal Bhatt on 13/01/26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct QuoteVaultWidgetControl: ControlWidget {
    @available(iOS 18.0, *)
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "QuoteVault.QuoteVaultWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension QuoteVaultWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

@available(iOS 16.0, *)
struct StartTimerIntent: SetValueIntent {
    @available(iOS 16, *)
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
