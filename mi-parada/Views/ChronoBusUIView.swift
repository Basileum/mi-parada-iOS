//
//  ChronoBusUIView.swift
//  mi-parada
//
//  Created by Basile on 04/07/2025.
//

import SwiftUI
import Charts



import SwiftUI

struct TimelineView: View {
    let totalMinutes: CGFloat = 20  // total timeline window
    let width: CGFloat = 300        // fixed width of the timeline
    
    // Marker times in minutes from now
    let marker1: CGFloat = 17
    let marker2: CGFloat = 3
    
    let showTicks: Bool = true
    let tickInterval: CGFloat = 1
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background timeline
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: 50)
            
            if showTicks {
                ForEach(0..<Int(totalMinutes / tickInterval) + 1, id: \.self) { i in
                    let minute = CGFloat(i) * tickInterval
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 4, height: 4)
                        .offset(x: positionTick(for: minute) - 2, y: 0)
                }
            }
            
            
            
            // Marker 1 (within 3 minutes)
            Image(systemName: "bus")
                .foregroundColor(.red)
                .frame(width: 20, height: 20)
                .offset(x: position(for: marker1) - 10, y: 0) // center the circle
            
            // Marker 2 (within 17 minutes)
            Image(systemName: "bus")
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
                .offset(x: position(for: marker2) - 10, y: 0)
            
            // Optional: Labels for markers
            Text("3 min")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: position(for: marker1) - 10, y: 40)
            
            Text("17 min")
                .font(.caption)
                .foregroundColor(.blue)
                .offset(x: position(for: marker2) - 15, y: 40)
        }
        .padding()
    }
    
    // Convert marker time (minutes) to x position on timeline
    func position(for minutes: CGFloat) -> CGFloat {
        // Clamp to the width range
        let clamped = min(max(minutes, 0), totalMinutes)
        // Map minutes to width proportionally
        return (clamped / totalMinutes) * width
    }
    
    private func positionTick(for minutes: CGFloat) -> CGFloat {
            let clamped = min(max(minutes, 0), totalMinutes)
            return (clamped / totalMinutes) * width
        }
}






struct ChronoBusUIView: View {
    
    var body: some View {
        HStack{
            TimelineView()
            Image("BusStop").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        }
    }
}
    



#Preview {
    ChronoBusUIView()
}
