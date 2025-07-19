//
//  widget.swift
//  widget
//
//  Created by jhkim on 2025.07.19.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // 위젯 미리보기
    func placeholder(in context: Context) -> SimpleEntry {
        let date = Calendar.current.date(byAdding: .minute, value: 35, to: Date())!
        return SimpleEntry(date: date, configuration: ConfigurationAppIntent())
    }
    
    // 위젯이 빠르게 화면에 표시되어야 할 때 보여줄 “임시” 데이터
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let date = Calendar.current.date(byAdding: .minute, value: 35, to: Date())!
        return SimpleEntry(date: date, configuration: configuration)
    }
    
    // 위젯의 콘텐츠를 시간 흐름에 따라 어떻게 갱신할지를 정의
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let entry = SimpleEntry(date: currentDate, configuration: configuration)
        print("🔄 timeline() called at \(Date())")
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(Constants.formattedRemainingTime(entry.date))
        }
    }
}

struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var sample1: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.descriptionText = "3시간 10분"
        return intent
    }
    
    fileprivate static var sample2: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.descriptionText = "10분"
        return intent
    }
}

#Preview(as: .systemSmall) {
    widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .sample1)
    SimpleEntry(date: .now, configuration: .sample2)
}

