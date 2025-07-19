//
//  HeaderView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//  메인 화면에서 상단 헤더

import SwiftUI

struct HeaderView: View {
    var isTimerRunning: Bool
    
    var body: some View {
        VStack {
            Image("headerIcon")
                .resizable()
                .frame(width: 158, height: 158)
            
            VStack(spacing: 6) {
                if isTimerRunning {
                    Text("퇴근이라는 희망의 빛이 보여요! 💡")
                        .font(.system(size: 24, weight: .bold))
                } else {
                    Text("칼퇴 요정과 함께 오늘도 칼퇴!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("오늘의 퇴근 시간을 알려주세요")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    HeaderView(isTimerRunning: false)
}
