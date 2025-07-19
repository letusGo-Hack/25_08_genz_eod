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
import ActivityKit
import WidgetKit

class ClockOutTimerViewModel: ObservableObject{
    @Published var timerString: String = "0:00:00"
    @Published var progress: CGFloat = 0
    @Published var showProgressAnimation: Bool = false
    @Published var settings: ClockOutSettings = ClockOutSettings()
    @Published var isAuthorized = false
    @Published var currentActivity: Activity<widgetAttributes>? = nil
    @Published var showingCongratulations = false
    @Published var isTimerRunning: Bool = false
    
    private var timer: Timer?
    private var initialTimerInterval: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
         NotificationCenter.default.publisher(for: OpenAppIntent.showCongratulationsNotification)
             .receive(on: DispatchQueue.main)
             .sink { [weak self] notification in
                 self?.handleAlarmNotification(notification)
             }
             .store(in: &cancellables)
     }
     
     private func handleAlarmNotification(_ notification: Notification) {
         // Stop timer and show congratulations
         stopAndResetTimer()
         showingCongratulations = true
         
         if let alarmID = notification.userInfo?["alarmID"] as? UUID {
             print("Alarm triggered with ID: \(alarmID)")
         }
         
         // 오늘 날짜로 데이터 저장 로직 추가
         // 오늘 날짜를 가져옵니다.
         let today = Calendar.current.component(.day, from: Date())
         
         var highlightedDays: [Int: HighlightType] = [:]
         // 오늘 날짜의 하이라이트 정보를 칼퇴 성공(초록색)으로 변경합니다.
         highlightedDays[today] = .earlyLeaveSuccess
         print("오늘 날짜(\(today)일) 칼퇴 성공으로 변경됨.")
         print("영구 하이라이트 날짜들: \(highlightedDays)")
         
         do {
             // [Int: HighlightType] 딕셔너리를 Data로 인코딩합니다.
             let encodedData = try JSONEncoder().encode(highlightedDays)
             UserDefaults.standard.set(encodedData, forKey: "highlightedDaysData")
             print("UserDefaults에 데이터 저장 성공: \(highlightedDays)")
         } catch {
             print("UserDefaults에 데이터 인코딩 및 저장 실패: \(error.localizedDescription)")
         }
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
        
        self.isTimerRunning = false
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
    
    func startTimer() {
        guard let clockOutTime = settings.clockOutTime else { return }
        
        timer?.invalidate()
        initialTimerInterval = clockOutTime.timeIntervalSince(Date())
        progress = calculateProgress()

        startLiveActivity(with: clockOutTime)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        self.isTimerRunning = true
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
             checkReminder(now: now, clockOutTime: clockOutTime)
            updateLiveActivity(clockOutTime: clockOutTime)
         } else {
             timerString = "퇴근할 시간 입니다!"
             timer?.invalidate()
             progress = 0
             endLiveActivity()
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
        print("show Reminder")
        
    }
    
    func setAlarm(with scheduleDate: Date,
                  isReminderAlarm: Bool,
                  reminderMinutes: Int? = nil) async throws {
        ///  Alarm ID
        let id = UUID()
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "퇴근하기",
                                          textColor: .white,
                                          systemImageName: "app.fill")
        /// Alert
        let alert = AlarmPresentation.Alert(
            title: !isReminderAlarm ? "야호~ 퇴근이다!!" : "퇴근 \(reminderMinutes ?? 5)분 전이에요. 조금만 더 힘을 내요!!",
            stopButton: .init(text: "알람끄기",
                              textColor: .red,
                              systemImageName: "stop.fill"),
            secondaryButton: !isReminderAlarm ? secondaryButton : nil,
            secondaryButtonBehavior: !isReminderAlarm ? .custom : nil)
        
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
            secondaryIntent: !isReminderAlarm ? OpenAppIntent(id: id): nil
        )
        
        /// Adding alarm to the System
        let _ = try await AlarmManager.shared.schedule(id: id,
                                         configuration: config)
        print("Alarm Set Successfully")
    }
    
    private func startLiveActivity(with clockOutTime: Date) {
        let attributes = widgetAttributes(region: .bottom)
        let state = widgetAttributes.ContentState(
            remainTime: Constants.formattedRemainingTimeHHMM(clockOutTime),
            progress: 1.0
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let activity = try Activity<widgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            self.currentActivity = activity
        } catch {
            print("❌ Live Activity 시작 실패: \(error)")
        }
    }
    
    private func updateLiveActivity(clockOutTime: Date) {
        guard let activity = currentActivity else { return }
        
        
        let doubleValue = Double(progress)
        let newProgress = (floor(doubleValue * 100) / 100) // - 0.1
        
        let state = widgetAttributes.ContentState(
            remainTime: Constants.formattedRemainingTimeHHMM(clockOutTime),
            progress: progress
        )

        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(content)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }

        let state = widgetAttributes.ContentState(
            remainTime: "퇴근!",
            progress: 0
        )
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
