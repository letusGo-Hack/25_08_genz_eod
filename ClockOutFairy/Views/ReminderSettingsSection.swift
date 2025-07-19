//
//  ReminderSettingsSection.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI

struct ReminderSettingsSection: View {
    @Binding var isReminderEnabled: Bool
    @Binding var reminderMinutes: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell")
                    .foregroundStyle(.accent)
                Text("퇴근 시간 전 알림 설정")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                HStack {
                    Text("퇴근 시간 전 알림")
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Toggle("", isOn: $isReminderEnabled)
                        .labelsHidden()
                }
                
                if isReminderEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("퇴근 시간 전 알림을 받습니다")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("알림 시간")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            
                            Spacer()
                            
                            Picker("", selection: $reminderMinutes) {
                                Text("퇴근 5분전").tag(5)
                                Text("퇴근 10분전").tag(10)
                                Text("퇴근 15분전").tag(15)
                                Text("퇴근 30분전").tag(30)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(.accent)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray6))
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ReminderSettingsSection(isReminderEnabled: .constant(true),
                            reminderMinutes: .constant(5))
}
