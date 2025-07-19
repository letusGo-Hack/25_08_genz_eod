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
            
            Button("▶️ Live Activity 시작") {
                startLiveActivityIfNeeded()
            }

            Button("⏹️ Live Activity 종료") {
                endLiveActivity()
            }
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
        let attributes = widgetAttributes(name: "Pairing")
        let state = widgetAttributes.ContentState(remainTime: Constants.formattedRemainingTimeHHMM(date))
        
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let activity = try Activity<widgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            Task {
                try await Task.sleep(for: .seconds(3))
                await activity.end(content, dismissalPolicy: .immediate)
                print("✅ 자동 종료됨")
            }
        } catch {
            print("❌ 시작 실패: \(error)")
        }
    }
    
    
    func endLiveActivity() {
        Task {
            for activity in Activity<widgetAttributes>.activities {
                let updatedState = widgetAttributes.ContentState(remainTime: "🛑")
                let content = ActivityContent(state: updatedState, staleDate: nil)
                await activity.end(content, dismissalPolicy: .immediate)
                print("🛑 Live Activity 종료됨: \(activity.id)")
            }
        }
    }
    

    func startLiveActivityIfNeeded() {

        guard Activity<widgetAttributes>.activities.isEmpty else { return }

        let attributes = widgetAttributes(name: "근무 종료 타이머")
        let state = widgetAttributes.ContentState(remainTime: "⏰")
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            _ = try Activity<widgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("✅ Live Activity 시작됨")
        } catch {
            print("❌ Live Activity 시작 실패: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
