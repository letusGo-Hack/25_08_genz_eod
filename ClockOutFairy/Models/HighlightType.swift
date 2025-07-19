//
//  HighlightType.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import Foundation
import SwiftUI

// 캘린더 날짜에 적용될 다양한 하이라이트 유형을 정의합니다.
// Codable 프로토콜을 추가하여 UserDefaults에 저장하고 불러올 수 있도록 합니다.
enum HighlightType: CaseIterable, Identifiable, Equatable, Codable {
    case selected // 기본 선택 (파란색) - 이 타입은 이제 currentlySelectedDay에서만 사용됩니다.
    case earlyLeaveSuccess // 칼퇴 성공 (초록색)
    case overtime // 야근 (칼퇴 실패와 통합됨)
    case annualHalfDayLeave // 연차 및 반차 (보라색)

    // Identifiable 프로토콜을 준수하여 ForEach 등에서 사용할 수 있도록 합니다.
    var id: Self { self }

    // 각 하이라이트 유형에 해당하는 색상을 반환합니다.
    var color: Color {
        switch self {
        case .selected:
            return Color.accentColor // SwiftUI의 기본 강조 색상 (보통 파란색)
        case .earlyLeaveSuccess:
            return Color(red: 0x75 / 255.0, green: 0xE3 / 255.0, blue: 0x46 / 255.0) // 초록색 (HEX: #75E346)
        case .overtime:
            return Color(red: 0xF6 / 255.0, green: 0xDF / 255.0, blue: 0x36 / 255.0) // 야근 (노란색 - 칼퇴 실패와 통합된 색상)
        case .annualHalfDayLeave:
            return Color(red: 0xE5 / 255.0, green: 0x00 / 255.0, blue: 0xFF / 255.0) // 보라색 (HEX: #E500FF)
        }
    }

    // Picker에 표시될 사용자 친화적인 설명 문자열을 반환합니다.
    var description: String {
        switch self {
        case .selected: return "선택됨" // 이 설명은 Picker에서 사용되지 않습니다.
        case .earlyLeaveSuccess: return "정시 퇴근"
        case .overtime: return "야근" // 칼퇴 실패와 통합된 설명
        case .annualHalfDayLeave: return "연차(반차)"
        }
    }

    // 설명 문자열로부터 HighlightType을 반환하는 정적 함수입니다.
    static func fromDescription(_ description: String) -> HighlightType? {
        switch description {
        case "정시 퇴근": return .earlyLeaveSuccess
        case "야근", "칼퇴 실패": return .overtime // "칼퇴 실패" 문자열도 야근으로 매핑
        case "연차(반차)": return .annualHalfDayLeave
        case "없음": return nil // "없음"은 실제 HighlightType이 아니므로 nil 반환
        default: return nil
        }
    }

    // 이 함수는 이제 사용되지 않습니다. Picker를 통해 직접 유형을 설정합니다.
    func next() -> HighlightType? {
        // 이 함수는 더 이상 캘린더 날짜 탭 시 하이라이트 유형 순환에 사용되지 않습니다.
        // Picker를 통해 직접 유형을 설정합니다.
        return nil
    }
}
