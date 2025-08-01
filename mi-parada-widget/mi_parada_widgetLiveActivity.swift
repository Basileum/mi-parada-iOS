//
//  mi_parada_widgetLiveActivity.swift
//  mi-parada-widget
//
//  Created by Basile on 18/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mi_parada_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mi_parada_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mi_parada_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                
                Text("Hello \(context.state.emoji)")
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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension mi_parada_widgetAttributes {
    fileprivate static var preview: mi_parada_widgetAttributes {
        mi_parada_widgetAttributes(name: "World")
    }
}

extension mi_parada_widgetAttributes.ContentState {
    fileprivate static var smiley: mi_parada_widgetAttributes.ContentState {
        mi_parada_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mi_parada_widgetAttributes.ContentState {
         mi_parada_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mi_parada_widgetAttributes.preview) {
   mi_parada_widgetLiveActivity()
} contentStates: {
    mi_parada_widgetAttributes.ContentState.smiley
    mi_parada_widgetAttributes.ContentState.starEyes
}
