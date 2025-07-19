//
//  ClockOutSettingsViewModel.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI
import Combine

class ClockOutSettingsViewModel: ObservableObject {
    @Published var selectedTime: Date = Date()
    @Published var reminderMinutes: Int = 5
    @Published var isReminderEnabled: Bool = true
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isAuthorized: Bool = false
    
    func loadSettings(from settings: ClockOutSettings) {
        if let time = settings.clockOutTime {
            selectedTime = time
        } else {
            setDefaultTime()
        }
        reminderMinutes = settings.reminderMinutes
        isReminderEnabled = settings.isReminderEnabled
    }
    
    private func setDefaultTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 18
        components.minute = 0
        selectedTime = calendar.date(from: components) ?? Date()
    }
    
    func validateAndCreateSettings() -> ClockOutSettings? {
        if selectedTime <= Date() {
            alertMessage = "퇴근 시간은 현재 시간보다 이후로 설정해주세요."
            showAlert = true
            return nil
        }
        
        return ClockOutSettings(
            clockOutTime: selectedTime,
            reminderMinutes: reminderMinutes,
            isReminderEnabled: isReminderEnabled
        )
    }
}
