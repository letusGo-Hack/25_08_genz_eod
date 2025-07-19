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
                                    
                                    
                                } else {
                                    showingSettings = true
                                }
                            }
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
