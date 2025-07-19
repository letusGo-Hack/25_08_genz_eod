//
//  AppIntent.swift
//  widget
//
//  Created by myungsun on 7/19/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "퇴근 위젯 설정" }
    static var description: IntentDescription { "퇴근까지 남은 시간을 설정합니다." }

    @Parameter(title: "퇴근까지 남은 시간(분)", default: 120)
    var remainingMinutes: Int

    @Parameter(title: "설명 텍스트", default: "퇴근까지 남음")
    var descriptionText: String
}
