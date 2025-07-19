//
//  AppButton.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//  메인, 상세 화면에서 사용하는 Custom Button

import SwiftUI

// 버튼 사용하는 화면 타입
enum ButtonSourceType {
    case main // 메인 화면
    case setting // 설정 화면
}

struct AppButton: View {
    let hasClockOutTime: Bool
    let type: ButtonSourceType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(getButtonText())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.accent)
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private func getButtonText() -> String {
        switch type {
        case .main:
            return hasClockOutTime ? "퇴근하기" : "퇴근시간 설정"
        case .setting:
            return "확인"
        }
    }
}

#Preview {
    AppButton(hasClockOutTime: false,
              type: .main) {}
}
