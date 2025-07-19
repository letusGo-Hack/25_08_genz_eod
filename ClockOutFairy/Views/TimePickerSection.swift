//
//  TimePickerSection.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI

struct TimePickerSection: View {
    @Binding var selectedTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("퇴근 시간")
                .font(.system(size: 16))
                .padding(.horizontal)
            
            HStack {
                DatePicker("",
                           selection: $selectedTime,
                           displayedComponents: .hourAndMinute)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                
                Spacer()
                
                Text(selectedTime, style: .time)
                    .font(.system(size: 18))
            }
            .padding()
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    TimePickerSection(selectedTime: .constant(Date()))
}
