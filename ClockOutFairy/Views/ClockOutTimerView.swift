//
//  ClockOutTimerView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//  메인 화면

import SwiftUI

struct ClockOutTimerView: View {
    @StateObject private var viewModel = ClockOutTimerViewModel()
    @State private var showingSettings = false
    @State private var showingCongratulations = false
    @Environment(\.scenePhase) private var scenePhase
    // 이 변수는 UserDefaults에 저장된 데이터를 불러오거나, 초기값을 설정합니다.
    @State private var highlightedDays: [Int: HighlightType] = [:]
    // UserDefaults에 데이터를 저장할 때 사용할 키입니다.
    private static let highlightedDaysKey = "highlightedDaysData"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    HeaderView(isTimerRunning: viewModel.isTimerRunning)
                    
                    TimerCardView(
                        timerString: viewModel.timerString,
                        progress: viewModel.progress,
                        showProgressAnimation: viewModel.showProgressAnimation,
                        hasClockOutTime: viewModel.settings.clockOutTime != nil
                    )
                    
                    Spacer()

                    AppButton(hasClockOutTime: viewModel.settings.clockOutTime != nil,
                              type: .main) {
                        if !viewModel.isAuthorized {
                                Task {
                                    do {
                                        try await viewModel.checkAndAuthorize()
                                        // Check if authorization was granted
                                        if viewModel.isAuthorized {
                                            showingSettings = true
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            } else {
                                if viewModel.settings.clockOutTime != nil {
                                    viewModel.stopAndResetTimer()
                                    viewModel.showingCongratulations = true
                                    
                                    // 오늘 날짜로 데이터 저장 로직 추가
                                    // 오늘 날짜를 가져옵니다.
                                    let today = Calendar.current.component(.day, from: Date())
                                    // 오늘 날짜의 하이라이트 정보를 칼퇴 성공(초록색)으로 변경합니다.
                                    highlightedDays[today] = .earlyLeaveSuccess
                                    print("오늘 날짜(\(today)일) 칼퇴 성공으로 변경됨.")
                                    print("영구 하이라이트 날짜들: \(highlightedDays)")
                                    
                                } else {
                                    showingSettings = true
                                }
                            }
                    }
                }.onChange(of: highlightedDays) {
                    // highlightedDays가 변경될 때마다 UserDefaults에 저장합니다.
                    do {
                        // [Int: HighlightType] 딕셔너리를 Data로 인코딩합니다.
                        let encodedData = try JSONEncoder().encode(highlightedDays)
                        UserDefaults.standard.set(encodedData, forKey: Self.highlightedDaysKey)
                        print("UserDefaults에 데이터 저장 성공: \(highlightedDays)")
                    } catch {
                        print("UserDefaults에 데이터 인코딩 및 저장 실패: \(error.localizedDescription)")
                    }
                } // VStack
            } // ZStack
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingSettings) {
                ClockOutSettingsView(currnetSetting: viewModel.settings) { newSettings in
                    viewModel.settings = newSettings
                    viewModel.setupTimer()
                    
                    if let scheduledDate = newSettings.clockOutTime {
                        if newSettings.isReminderEnabled {
                            let reminderTime = scheduledDate.addingTimeInterval(-Double(newSettings.reminderMinutes * 60))
                            
                            Task {
                                do {
                                    try await viewModel.setAlarm(with: reminderTime,
                                                                 isReminderAlarm: true,
                                                                 reminderMinutes: newSettings.reminderMinutes)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        
                        Task {
                            do {
                                try await viewModel.setAlarm(with: scheduledDate,
                                                             isReminderAlarm: false)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            .overlay {
                   // Custom Alert
                if viewModel.showingCongratulations {
                       CongratulationsAlertView(
                        isPresented: $viewModel.showingCongratulations,
                           onDismiss: { }
                       )
                   }
               }
        } // NavigationStack
        .onAppear {
            viewModel.updateTimerIfNeeded()
            
            // Check authorization status on appear
            Task {
                await viewModel.checkAuthorizationStatus()
            }
        }
    }
}

#Preview {
    ClockOutTimerView()
}
