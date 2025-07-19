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
    
    var imageName: String = "Dynamic_Island_Check"
}

struct widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: widgetAttributes.self) { context in
            let progress = min(1.0, max(0.0, context.state.progress))
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Text("칼퇴까지 \(context.state.remainTime)")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.leading, 15)
                        Spacer()
                    }
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width, height: 12)

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 12)
                        
                        Image(systemName: "figure.run")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .offset(x: geometry.size.width * progress - 10, y: -20)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                            .foregroundStyle(.black)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .activityBackgroundTint(Color.white.opacity(0.5))
                .activitySystemActionForegroundColor(Color.white.opacity(0.5))
            }
            .frame(height: 100)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    if context.attributes.region == .bottom {
                        GeometryReader { geometry in
                            // TODO: 수정 필요!
                            let progress = min(1.0, max(0.0, context.state.progress))
                            
                            VStack {
                                Spacer()

                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)

                                    Capsule()
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * progress, height: 12)

                                    Image(systemName: "figure.run")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .offset(x: geometry.size.width * progress - 10, y: -16)
                                        .animation(.easeInOut(duration: 0.3), value: progress)
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                        .frame(height: 40)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    if context.attributes.region == .center {
                        Text("Center 영역")
                    }
                }

                DynamicIslandExpandedRegion(.leading) {
                    if context.attributes.region == .compact {
                        Text("Leading")
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.attributes.region == .compact {
                        Text("Trailing")
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

