//
//  OpenAppIntent.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import AppIntents
import Foundation

struct OpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Opens App"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false
    
    // Notification name for showing congratulations
    static let showCongratulationsNotification = Notification.Name("ShowCongratulationsNotification")
    
    @Parameter
    var id: String
    
    init(id: UUID) {
        self.id = id.uuidString
    }
    
    init() {
        
    }
    
    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: id) {
            print(alarmID)
            
            // Post notification to show congratulations
            await MainActor.run {
                NotificationCenter.default.post(
                    name: OpenAppIntent.showCongratulationsNotification,
                    object: nil,
                    userInfo: ["alarmID": alarmID]
                )
            }
            
            print("open App Intent Called - Congratulations notification posted")
        }
        
        return .result()
    }
}
