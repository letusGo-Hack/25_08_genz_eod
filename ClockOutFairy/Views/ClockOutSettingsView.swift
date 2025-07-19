//
//  ClockOutSettingsView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//  퇴근 시간 설정 화면

import SwiftUI

struct ClockOutSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ClockOutSettingsViewModel()
    
    let currnetSetting: ClockOutSettings
    let onSave: (ClockOutSettings) -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationHeader {
                    dismiss()
                } onIconImageClicked: {
                    
                    
                    
                }

                ScrollView {
                    VStack(spacing: 20) {
                        TimePickerSection(selectedTime: $viewModel.selectedTime)
                        
                        ReminderSettingsSection(
                            isReminderEnabled: $viewModel.isReminderEnabled,
                            reminderMinutes: $viewModel.reminderMinutes
                        )
                    }
                    .padding(.vertical)
                }
                
                AppButton(hasClockOutTime: false,
                          type: .setting) {
                    if let newSettings = viewModel.validateAndCreateSettings() {
                          onSave(newSettings)
                          dismiss()
                      }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadSettings(from: currnetSetting)
        }
        .alert("퇴근 시간 설정 오류", isPresented: $viewModel.showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
//    ClockOutSettingsView(cl)
}
