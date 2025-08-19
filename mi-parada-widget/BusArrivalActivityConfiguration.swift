//
//  mi_parada_widgetLiveActivity.swift
//  mi-parada-widget
//
//  Created by Basile on 18/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI


struct BusArrivalWidgetLiveActivity: Widget {
    

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusArrivalAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 16) {
                // Header with bus line and stop info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                            HStack(spacing: 6) {
                                Image(systemName: "bus.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                Text("\(context.attributes.watchStop.busLine.label)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(6)
                            
                            HStack{
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                Text(context.attributes.watchStop.busLine.externalTo)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
            
                    
                    Spacer()
                    
                    Text(context.attributes.watchStop.busStop.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
//                    // Bus line number with enhanced styling
//                    LineNumberView(busLine: context.attributes.watchStop.busLine)
//                        .frame(width: 50, height: 50)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                }
                
                // Timeline with bus approaching
                BusTimelineView(
                    estimatedArrival: context.state.busEstimatedArrival,
                    secondBusEstimatedArrival: context.state.secondBusEstimatedArrival
                )
                
                // Enhanced arrival time display
                HStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("NEXT")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.busEstimatedArrival))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                        }
                        
                        Spacer()
                        
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("2ND")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.secondBusEstimatedArrival))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                        }.padding(.leading, 20)
                        Spacer()
                    }
                    
//                    Spacer()
//                    
//                    // Status indicator
//                    HStack(spacing: 6) {
//                        Circle()
//                            .fill(getStatusColor(context.state.busEstimatedArrival))
//                            .frame(width: 10, height: 10)
//                        
//                        Text(getStatusText(context.state.busEstimatedArrival))
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color.black.opacity(0.3))
//                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.white)
            .onChange(of: context.state) { newState in
                logger.info(" Live Activity updated from server push:")
                logger.info(" ETA: \(newState.busEstimatedArrival) seconds")
                logger.info(" 2nd ETA: \(newState.secondBusEstimatedArrival ?? -1) seconds")
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "bus.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                Text("\(context.attributes.watchStop.busLine.label)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(6)
                            
                            HStack{
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                Text(context.attributes.watchStop.busLine.externalTo)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .center, spacing: 2) {
                        HStack{
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.busEstimatedArrival))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        VStack{
                            Text("NEXT:")
                                .font(.caption)
                            Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.secondBusEstimatedArrival))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }.padding(.trailing, 15)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.attributes.watchStop.busStop.name)")
                        .font(.title2)
                        .padding(.vertical, 10)
                }
            } compactLeading: {
                SmallLineNumberView(busLine: context.attributes.watchStop.busLine)
                    .frame(width: 50, height: 20)
                    .padding(.leading)
            } compactTrailing: {
                Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.busEstimatedArrival))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            } minimal: {
                Text(ArrivalFormatsTime.simpleFormatArrivalTime(context.state.busEstimatedArrival))
                    .font(.system(size: 11))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .widgetURL(URL(string: "mi-parada://bus-arrival"))
            .keylineTint(Color.blue)
            .contentMargins(.trailing, 8, for: .expanded)
            .contentMargins(.all, 20, for: .expanded)
        }
        
    }
}

// MARK: - Helper Functions
extension BusArrivalWidgetLiveActivity {
    private func getStatusColor(_ arrivalTime: Int) -> Color {
        // Convert seconds to minutes for status color
        let minutes = arrivalTime / 60
        switch minutes {
        case 0...2:
            return .red
        case 3...5:
            return .orange
        default:
            return .blue
        }
    }
    
    private func getStatusText(_ arrivalTime: Int) -> String {
        // Convert seconds to minutes for status text
        let minutes = arrivalTime / 60
        switch minutes {
        case 0...2:
            return "Arriving"
        case 3...5:
            return "Approaching"
        default:
            return "On the way"
        }
    }
}

// MARK: - Bus Timeline View
struct BusTimelineView: View {
    let estimatedArrival: Int
    let secondBusEstimatedArrival: Int? // Optional additional buses
    
    // Calculate bus position based on estimated arrival time (in seconds)
    private var busProgress: Double {
        // Convert arrival time to progress (0.0 to 1.0)
        // Bus starts at 0% when maxTime seconds away and reaches 100% when arriving (0 seconds)
        let maxTime = 22.0 * 60.0 // 22 minutes in seconds
        let currentTime = Double(estimatedArrival)
        let progress = (maxTime - currentTime) / maxTime
        print("busProgress: \(progress)")
        return progress
    }
    
    private var secondBusProgress: Double {
        guard let secondBusEstimatedArrival = self.secondBusEstimatedArrival else {
            return -1
        }
        print("secondBusEstimatedArrival: \(secondBusEstimatedArrival)")
        // Convert arrival time to progress (0.0 to 1.0)
        // Bus starts at 0% when maxTime seconds away and reaches 100% when arriving (0 seconds)
        let maxTime2 = 22.0 * 60.0 // 22 minutes in seconds
        let currentTime2 = Double(secondBusEstimatedArrival)
        let progress2 = max(0.0, min(1.0, (maxTime2 - currentTime2) / maxTime2))
        print("secondBusProgress: \(progress2)")
        return progress2
    }
    
    // Get color based on arrival time
    private var progressColor: Color {
        switch estimatedArrival {
        case 0...2:
            return .red
        case 3...5:
            return .orange
        default:
            return .white
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Timeline track with enhanced design
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(width:  UIScreen.main.bounds.width * 0.9, height: 8)
                
                // Progress track
                RoundedRectangle(cornerRadius: 4)
                    .fill(progressColor)
                    .frame(width: UIScreen.main.bounds.width * 0.9 * (busProgress), height: 8)
                
                // All bus icons (main + additional)
                Group {
                    // Main bus icon (larger, more prominent)
                    BusIconView(
                        progress: busProgress,
                        isMain: true,
                        arrivalTime: estimatedArrival
                    )
                    
                    if let secondBusEstimatedArrival = secondBusEstimatedArrival {
                        BusIconView(
                            progress: secondBusProgress,
                            isMain: false,
                            arrivalTime: secondBusEstimatedArrival
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Bus Icon View
struct BusIconView: View {
    let progress: Double
    let isMain: Bool
    let arrivalTime: Int
    @State private var animatedProgress: Double = 0
    @State private var lastUpdateTime: Date = Date()
    
    private var busColor: Color {
        if isMain {
            return .white
        } else {
            return .white.opacity(0.7)
        }
    }
    
    private var busSize: Font {
        if isMain {
            return .title3
        } else {
            return .caption
        }
    }
    
    private var shadowRadius: CGFloat {
        if isMain {
            return 3
        } else {
            return 2
        }
    }
    
    private var backgroundSize: CGFloat {
        if isMain {
            return 32
        } else {
            return 24
        }
    }
    
    private var backgroundColor: Color {
        if isMain {
            return .blue
        } else {
            return .blue.opacity(0.6)
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                // Circular background
                Circle()
                    .fill(backgroundColor)
                    .frame(width: backgroundSize, height: backgroundSize)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                // Bus icon
                Image(systemName: "bus.fill")
                    .font(busSize)
                    .foregroundColor(busColor)
            }
            .offset(x:UIScreen.main.bounds.width * 0.9 * -(1-progress))
//            .scaleEffect(1.0 + (animatedProgress * 0.1)) // Slight scale effect as bus gets closer
//            .opacity(0.8 + (animatedProgress * 0.2)) // Slight opacity change as bus gets closer
        }
        //.frame(width: UIScreen.main.bounds.width * 0.5)
        .onAppear {
            //startContinuousAnimation()
        }
        .onChange(of: progress) { newProgress in
            // When server updates the progress, smoothly transition to new value
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = newProgress
            }
            lastUpdateTime = Date()
        }
    }
    
    // MARK: - Animation Logic
    private func startContinuousAnimation() {
        // Start with current progress
        animatedProgress = progress
        
        // Create a timer that updates every 500ms for smoother animation
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            let now = Date()
            let timeSinceUpdate = now.timeIntervalSince(lastUpdateTime)
            
            // Calculate how much the bus should have moved based on time elapsed
            let secondsElapsed = timeSinceUpdate
            
            // Calculate progress increment based on estimated arrival time (in seconds)
            let maxTime = 22.0 * 60.0 // 22 minutes in seconds
            let progressIncrementPerSecond = 1.0 / maxTime // 1.0 progress over maxTime seconds
            
            // Update animated progress
            let newProgress = min(1.0, animatedProgress + (progressIncrementPerSecond * secondsElapsed))
            
            withAnimation(.linear(duration: 0.5)) {
                animatedProgress = newProgress
            }
        }
    }
}

extension BusArrivalAttributes {
    fileprivate static var preview: BusArrivalAttributes {
        
        BusArrivalAttributes(
            watchStop: WatchStop(
                busLine: BusLine(
                    id: "024",
                    label: "24",
                    externalFrom: "from",
                    externalTo: "to",
                    colorBackground: "#00aecf",
                    colorForeground: "#ffffff"),
                busStop: BusStop(
                    id: 2185,
                    name: "Test",
                    coordinate: Coordinate(
                        latitude: 40.39137392789779,
                        longitude: -3.666371843698435
                    )),
                dateOfWatchStart: Date()
            )
        )
    }
}

extension BusArrivalAttributes.ContentState {
    fileprivate static var time5mn: BusArrivalAttributes.ContentState {
        BusArrivalAttributes.ContentState(
            busEstimatedArrival: 120,
            secondBusEstimatedArrival: 480)
     }
     
     fileprivate static var time3mn: BusArrivalAttributes.ContentState {
         BusArrivalAttributes.ContentState(busEstimatedArrival: 60,
                   secondBusEstimatedArrival: 120)
     }
}

#Preview("Lock Screen", as: .content, using: BusArrivalAttributes.preview) {
    BusArrivalWidgetLiveActivity()
} contentStates: {
    BusArrivalAttributes.ContentState.time5mn
}

#Preview("Dynamic Island - Compact", as: .dynamicIsland(.compact), using: BusArrivalAttributes.preview) {
    BusArrivalWidgetLiveActivity()
} contentStates: {
    BusArrivalAttributes.ContentState.time5mn
}

#Preview("Dynamic Island - Minimal", as: .dynamicIsland(.minimal), using: BusArrivalAttributes.preview) {
    BusArrivalWidgetLiveActivity()
} contentStates: {
    BusArrivalAttributes.ContentState.time5mn
}

#Preview("Dynamic Island - Expanded", as: .dynamicIsland(.expanded), using: BusArrivalAttributes.preview) {
    BusArrivalWidgetLiveActivity()
} contentStates: {
    BusArrivalAttributes.ContentState.time5mn
}
