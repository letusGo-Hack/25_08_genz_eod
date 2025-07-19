//
//  AppIntent.swift
//  widget
//
//  Created by jhkim on 2025.07.19.
//

import WidgetKit
import AppIntents
import Foundation

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "GenZ" }
    static var description: IntentDescription { "End Of Date Widget." }

    @Parameter(title: "time", default: "몇분")
    var descriptionText: String
    
    @Parameter(title: "시간(분)", default: Date.now)
    var durationMinutes: Date
}
