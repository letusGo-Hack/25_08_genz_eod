//
//  widgetControl.swift
//  widget
//
//  Created by jhkim on 2025.07.19.
//

import AppIntents
import SwiftUI
import WidgetKit

struct widgetControl: ControlWidget {
    
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Constants.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(name: value.name, value: !value.isRunning)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName(Constants.displayName)
        .description(Constants.description)
    }
}

extension widgetControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            widgetControl.Value(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return widgetControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Name Configuration"

    @Parameter(title: "Timer Name", default: "Timer")
    var timerName: String
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer Name")
    var name: String

    @Parameter(title: "Timer is running")
    var value: Bool

    init() {}

    init(name: String, value: Bool) {
        self.name = name
        self.value = value
    }

    func perform() async throws -> some IntentResult {
        // Start the timer…
        return .result()
    }
}
