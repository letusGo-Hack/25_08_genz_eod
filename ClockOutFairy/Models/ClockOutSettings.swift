//
//  ClockOutSettings.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import Foundation
import AlarmKit

nonisolated
struct ClockOutSettings: AlarmMetadata, Hashable, Sendable {
    var clockOutTime: Date?
    var reminderMinutes: Int = 5
    var isReminderEnabled: Bool = false
}
