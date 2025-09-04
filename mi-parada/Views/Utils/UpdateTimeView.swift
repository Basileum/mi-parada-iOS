//
//  UpdateTimeView.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI

struct UpdateTimeView: View {
    let lastUpdateTime: Date?
    @State private var timeSinceUpdate: String = "Connecting..."
    @State private var timer: Timer?
    @State private var currentUpdateTime: Date?
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(getStatusColor())
                .frame(width: 6, height: 6)
            
            Text(timeSinceUpdate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            currentUpdateTime = lastUpdateTime
            startTimer()
            updateTimeString()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: lastUpdateTime) { newValue in
            currentUpdateTime = newValue
            updateTimeString()
        }
    }
    
    private func getStatusColor() -> Color {
        guard let lastUpdate = currentUpdateTime else {
            return .orange // Connecting/loading
        }
        
        let timeInterval = Date().timeIntervalSince(lastUpdate)
        if timeInterval < 30 {
            return .green // Recent update
        } else if timeInterval < 60 {
            return .yellow // Getting stale
        } else {
            return .red // Stale
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeString()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeString() {
        guard let lastUpdate = currentUpdateTime else {
            timeSinceUpdate = "Connecting..."
            return
        }
        
        let timeInterval = Date().timeIntervalSince(lastUpdate)
        
        if timeInterval < 5 {
            timeSinceUpdate = "Just updated"
        } else if timeInterval < 15 {
            timeSinceUpdate = "5 seconds ago"
        } else if timeInterval < 30 {
            timeSinceUpdate = "15 seconds ago"
        } else if timeInterval < 60 {
            timeSinceUpdate = "30 seconds ago"
        } else if timeInterval < 300 { // 5 minutes
            let minutes = Int(timeInterval / 60)
            timeSinceUpdate = "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 3600 { // 1 hour
            let minutes = Int(timeInterval / 60)
            timeSinceUpdate = "\(minutes) minutes ago"
        } else {
            let hours = Int(timeInterval / 3600)
            timeSinceUpdate = "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        UpdateTimeView(lastUpdateTime: Date())
        UpdateTimeView(lastUpdateTime: Date().addingTimeInterval(-30))
        UpdateTimeView(lastUpdateTime: Date().addingTimeInterval(-120))
        UpdateTimeView(lastUpdateTime: nil)
    }
    .padding()
}