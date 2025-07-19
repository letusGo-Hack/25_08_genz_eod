//
//  widgetLiveActivity.swift
//  widget
//
//  Created by jhkim on 2025.07.19.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainTime: String
        
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    
    var imageName: String = "Dynamic_Island_Check"
}

struct widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.remainTime)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.remainTime)")
                    // more content
                }
            } compactLeading: {
                Text("\(context.state.remainTime)")
            } compactTrailing: {
                Image(context.attributes.imageName)
            } minimal: {
                Text(context.state.remainTime)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension widgetAttributes {
    fileprivate static var preview: widgetAttributes {
        widgetAttributes(name: "World")
    }
}

extension widgetAttributes.ContentState {
    fileprivate static var smiley: widgetAttributes.ContentState {
        widgetAttributes.ContentState(remainTime: "😀")
     }
     
     fileprivate static var starEyes: widgetAttributes.ContentState {
         widgetAttributes.ContentState(remainTime: "🤩")
     }
}

#Preview("Notification", as: .content, using: widgetAttributes.preview) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.smiley
    widgetAttributes.ContentState.starEyes
}
