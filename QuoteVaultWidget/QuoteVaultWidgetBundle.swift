//
//  QuoteVaultWidgetBundle.swift
//  QuoteVaultWidget
//
//  Created by Payal Bhatt on 13/01/26.
//

import WidgetKit
import SwiftUI

@main
struct QuoteVaultWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteVaultWidget()
        // Live Activities and Controls are not required for basic widget functionality
        // QuoteVaultWidgetControl()
        // QuoteVaultWidgetLiveActivity()
    }
}
