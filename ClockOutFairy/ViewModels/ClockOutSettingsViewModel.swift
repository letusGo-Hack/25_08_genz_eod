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
        let now = Date()
        
        // Check if clock-out time is in the past
        if selectedTime <= now {
            alertMessage = "퇴근 시간은 현재 시간보다 이후로 설정해주세요."
            showAlert = true
            return nil
        }
        
        // Check reminder time validity if reminder is enabled
        if isReminderEnabled {
            let reminderTime = selectedTime.addingTimeInterval(-Double(reminderMinutes * 60))
            
            // Check if reminder time has already passed
            if reminderTime <= now {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let selectedTimeString = formatter.string(from: selectedTime)
                let currentTimeString = formatter.string(from: now)
                
                alertMessage = """
                 알림 시간이 이미 지났습니다.
                 
                 현재 시간: \(currentTimeString)
                 퇴근 시간: \(selectedTimeString)
                 알림 설정: \(reminderMinutes)분 전
                 
                 퇴근 시간을 더 늦게 설정하거나 알림 시간을 줄여주세요.
                 """
                showAlert = true
                return nil
            }
            
            let timeUntilReminder = reminderTime.timeIntervalSince(now)
            if timeUntilReminder < 60 { // Less than 1 minute
                alertMessage = """
                 알림 시간까지 1분도 남지 않았습니다.
                 퇴근 시간을 조정하거나 알림을 비활성화해주세요.
                 """
                showAlert = true
                return nil
            }
        }
        
        return ClockOutSettings(
            clockOutTime: selectedTime,
            reminderMinutes: reminderMinutes,
            isReminderEnabled: isReminderEnabled
        )
    }
}
