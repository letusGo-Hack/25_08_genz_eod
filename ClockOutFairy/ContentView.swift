//
//  ContentView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                startAndAutoEndActivity()
            }
        }
    }
    
    func startAndAutoEndActivity() {
        let date = Calendar.current.date(byAdding: .minute, value: 135, to: Date())!
        //let attributes = widgetAttributes(region: .compact)
        let attributes = widgetAttributes(region: .bottom)
        let state = widgetAttributes.ContentState(remainTime: Constants.formattedRemainingTimeHHMM(date), progress: 0.3)
        
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let activity = try Activity<widgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            Task {
                try await Task.sleep(for: .seconds(30))
                await activity.end(content, dismissalPolicy: .immediate)
                // dismissalPolicy: .after(Date().addingTimeInterval(5)
                print("✅ 자동 종료됨")
            }
        } catch {
            print("❌ 시작 실패: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
