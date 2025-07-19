//
//  ClockOutTimerViewModel.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import Foundation
import Combine
import SwiftUI
import AlarmKit

class ClockOutTimerViewModel: ObservableObject{
    @Published var timerString: String = "0:00:00"
    @Published var progress: CGFloat = 0
    @Published var showProgressAnimation: Bool = false
    @Published var settings: ClockOutSettings = ClockOutSettings()
    @Published var isAuthorized = false
    
    private var timer: Timer?
    private var initialTimerInterval: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func checkAuthorizationStatus() async {
         await MainActor.run {
             switch AlarmManager.shared.authorizationState {
             case .authorized:
                 isAuthorized = true
             case .denied, .notDetermined:
                 isAuthorized = false
             @unknown default:
                 isAuthorized = false
             }
         }
     }
     
     func checkAndAuthorize() async throws {
         switch AlarmManager.shared.authorizationState {
         case .notDetermined:
             /// Requesting for authorization
             let status = try await AlarmManager.shared.requestAuthorization()
             await MainActor.run {
                 isAuthorized = status == .authorized
             }
         case .denied:
             await MainActor.run {
                 isAuthorized = false
             }
         case .authorized:
             await MainActor.run {
                 isAuthorized = true
             }
         @unknown default:
             fatalError()
         }
     }
    
    private func setupBindings() {
        $settings
            .sink { [weak self] _ in
                self?.updateTimerIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    func updateTimerIfNeeded() {
        if settings.clockOutTime != nil && initialTimerInterval > 0 {
            startTimer()
        }
    }
    
    func setupTimer() {
        guard let clockOutTime = settings.clockOutTime else { return }
        
        initialTimerInterval = clockOutTime.timeIntervalSince(Date())
        
        // start Timer
        startTimer()
        
        // Trigger animation
        animateProgress()
    }
    
    func stopAndResetTimer() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Reset all values
        timerString = "0:00:00"
        progress = 0
        initialTimerInterval = 0
        
        // Clear clock out time
        settings.clockOutTime = nil
    }
    
    private func animateProgress() {
        showProgressAnimation = true
        progress = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.progress = self?.calculateProgress() ?? 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.showProgressAnimation = false
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        progress = calculateProgress()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.updateTimer()
        })
    }
    
    private func updateTimer() {
        guard let clockOutTime = settings.clockOutTime else { return }
        
        let now = Date()
        let timeInterval = clockOutTime.timeIntervalSince(now)
        
        if timeInterval > 0 {
             let hours = Int(timeInterval) / 3600
             let minutes = Int(timeInterval) % 3600 / 60
             let seconds = Int(timeInterval) % 60
             
             timerString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
             
             // 프로그래스 업데이트
             if !showProgressAnimation {
                 progress = calculateProgress()
             }
             
             // 리마인더 체크
             checkReminder(now: now,
                           clockOutTime: clockOutTime)
         } else {
             timerString = "퇴근할 시간 입니다!"
             timer?.invalidate()
             progress = 0
         }
    }
    
    private func checkReminder(now: Date,
                               clockOutTime: Date) {
        guard settings.isReminderEnabled else { return }
        
        let reminderTime = clockOutTime.addingTimeInterval(-Double(settings.reminderMinutes * 60))
        if now >= reminderTime && now < reminderTime.addingTimeInterval(1) {
            showReminder()
        }
    }
    
    private func calculateProgress() -> CGFloat {
        guard let clockOutTime = settings.clockOutTime else { return 0 }
        
        let now = Date()
        let remainingTime = clockOutTime.timeIntervalSince(now)
        
        if remainingTime <= 0 {
            return 0
        }
        
        if initialTimerInterval <= 0 {
            return 0
        }
        
        return max(remainingTime / initialTimerInterval, 0)
        
    }
    
    private func showReminder() {
        // TODO: AlarmKit 사용
        
    }
    
    func setAlarm(with scheduleDate: Date) async throws {
        ///  Alarm ID
        let id = UUID()
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "퇴근하기",
                                          textColor: .white,
                                          systemImageName: "app.fill")
        /// Alert
        let alert = AlarmPresentation.Alert(
            title: "야호~ 퇴근이다!!",
            stopButton: .init(text: "퇴근하기",
                              textColor: .red,
                              systemImageName: "stop.fill"),
            secondaryButton: nil,
            secondaryButtonBehavior: .none)
        
        /// Presentation
        let presentation = AlarmPresentation(alert: alert)
        
        /// Attributes
        let attributes = AlarmAttributes<ClockOutSettings>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Schedule
        let schedule = Alarm.Schedule.fixed(scheduleDate)
        
        /// Configuration
        let config = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: nil
        )
        
        /// Adding alarm to the System
        let _ = try await AlarmManager.shared.schedule(id: id,
                                         configuration: config)
        print("Alarm Set Successfully")
    }
    
    deinit {
        timer?.invalidate()
    }
}
