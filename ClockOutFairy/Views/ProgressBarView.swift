//
//  ProgressBarView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//  남은 퇴근 시간 상태를 나타내는 ProgressBar

import SwiftUI

struct ProgressBarView: View {
    let progress: CGFloat
    let showProgressAnimation: Bool
    let hasClockOutTime: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 20)
                
                if hasClockOutTime {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.orange)
                        .frame(width: progress * geometry.size.width, height: 20)
                        .animation(.easeInOut(duration: showProgressAnimation ? 1.0 : 0.1), value: progress)
                }
            }
        }
        .frame(height: 20)
        .padding(.horizontal, 30)
    }
}

#Preview {
    ProgressBarView(
        progress: 0.5,
        showProgressAnimation: false,
        hasClockOutTime: true
    )
}
