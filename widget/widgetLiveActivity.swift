//
//  widgetLiveActivity.swift
//  widget
//
//  Created by jhkim on 2025.07.19.
//

import ActivityKit
import WidgetKit
import SwiftUI

enum RegionPosition: String, Codable, Hashable {
    case minimal
    case bottom
    case center
    case compact
}

struct widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainTime: String
        var progress: Double
    }
    
    var region: RegionPosition
    
    var imageName: String = "timer"
}

struct widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: widgetAttributes.self) { context in
            let progress = min(1.0, max(0.0, context.state.progress))
            
            GeometryReader { geometry in
                progressGaugeView(progress: progress, remainTime: context.state.remainTime, width: geometry.size.width)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .activityBackgroundTint(Color.clear)
                    .activitySystemActionForegroundColor(Color.clear)
            }
            .frame(height: 100)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // TODO: 수정 필요!!
                DynamicIslandExpandedRegion(.bottom) {
                    if context.attributes.region == .bottom {
                        let progress = min(1.0, max(0.0, context.state.progress))
                        progressGaugeView(progress: progress, remainTime: context.state.remainTime, width: 100)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    if context.attributes.region == .center {
                        let progress = min(1.0, max(0.0, context.state.progress))
                        progressGaugeView(progress: progress, remainTime: context.state.remainTime, width: 100)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }

                DynamicIslandExpandedRegion(.leading) {
                    if context.attributes.region == .compact {
                        Text("\(context.state.remainTime)")
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.attributes.region == .compact {
                        Image(context.attributes.imageName)
                    }
                }
            }
            compactLeading: {
                Text("\(context.state.remainTime)")
            } compactTrailing: {
                Image(context.attributes.imageName)
            } minimal: {
                Image(context.attributes.imageName)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.blue)
        }
    }
    
    @ViewBuilder
    func progressGaugeView(progress: Double, remainTime: String, width: CGFloat) -> some View {
        VStack {
            HStack {
                Text("칼퇴까지 \(remainTime)")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.leading, 15)
                Spacer()
            }
            // FIXME: 길이 짤리는 문제 발생
            let tempWidth = width - 50
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: tempWidth, height: 12)

                Capsule()
                    .fill(Color.blue)
                    .frame(width: tempWidth, height: 12)

                Image(systemName: "figure.run")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .offset(x: tempWidth * progress - 10, y: -20)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                    .foregroundStyle(.black)
            }
            .padding()
        }
    }
}

extension widgetAttributes {
    fileprivate static var previewBottom: widgetAttributes {
        widgetAttributes(region: .bottom)
    }
    
    fileprivate static var previewCenter: widgetAttributes {
        widgetAttributes(region: .center)
    }
}

extension widgetAttributes.ContentState {
    fileprivate static var temp: widgetAttributes.ContentState {
        widgetAttributes.ContentState(remainTime: "13:23", progress: 0.3)
     }
}


#Preview("Lock Screen", as: .content, using: widgetAttributes.previewBottom) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.temp
}


#Preview("Compact", as: .dynamicIsland(.compact), using: widgetAttributes.previewBottom) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.temp
}


#Preview("Center", as: .dynamicIsland(.expanded), using: widgetAttributes.previewCenter) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.temp
}

#Preview("Bottom", as: .dynamicIsland(.expanded), using: widgetAttributes.previewBottom) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.temp
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: widgetAttributes.previewCenter) {
   widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.temp
}

