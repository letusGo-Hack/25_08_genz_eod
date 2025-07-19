//
//  TimerCardView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI

struct TimerCardView: View {
    let timerString: String
    let progress: CGFloat
    let showProgressAnimation: Bool
    let hasClockOutTime: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.accent)
            
            VStack(spacing: 20) {
                Text(timerString)
                    .font(timerString.contains(":") ? .system(size: 60, weight: .bold, design: .default) : .system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ProgressBarView(progress: progress,
                                showProgressAnimation: showProgressAnimation,
                                hasClockOutTime: hasClockOutTime)
            }
            .padding(.vertical,
                     timerString.contains(":") || timerString == "0:00:00" ? 20 : 30)
        }
        .frame(height: 140)
        .padding(.horizontal, 40)
    }
}

#Preview {
    TimerCardView(timerString: "0:00:00",
                  progress: 1,
                  showProgressAnimation: false,
                  hasClockOutTime: false)
}
