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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    HeaderView()
                    
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
                                    showingCongratulations = true
                                    
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
                        Task {
                            do {
                                try await viewModel.setAlarm(with: scheduledDate)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                    // TODO: viewModel에서 AlarmKit 사용한 메서드 호출하기
                }
            }
            .overlay {
                   // Custom Alert
                   if showingCongratulations {
                       CongratulationsAlertView(
                           isPresented: $showingCongratulations,
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                viewModel.startAndAutoEndActivity()
            }
        }
    }
}

#Preview {
    ClockOutTimerView()
}
