//
//  Constants.swift
//  ClockOutFairy
//
//  Created by jhkim on 2025.07.19.
//

import Foundation

struct Constants {
    static let kind = "kr.genz.ClockOutFairy.widget"
    static let displayName: LocalizedStringResource = "GenZ Widget"
    static let description: LocalizedStringResource = "End Of Date Widget."
    
    static let formattedRemainingTime: (Date) -> String = { targetDate in
        let now = Date()
        let interval = Int(targetDate.timeIntervalSince(now))
        
        guard interval > 0 else { return "시간이 지났습니다." }
        
        if interval < 60 { return "\(interval)초 남았습니다." }

        let totalMinutes = interval / 60
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            if minutes == 0 {
                return "\(hours)시간 남았습니다."
            } else {
                return "\(hours)시간 \(minutes)분 남았습니다."
            }
        } else {
            return "\(totalMinutes)분 남았습니다."
        }
    }
    
    static let formattedRemainingTimeHHMM: (Date) -> String = { targetDate in
        let now = Date()
        let interval = Int(targetDate.timeIntervalSince(now))
        
        if interval < 60 {
            return "\(interval)s"
        }
        
        guard interval > 0 else { return "" }

        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        
        return String(format: "%02d:%02d", hours, minutes)
    }
}
