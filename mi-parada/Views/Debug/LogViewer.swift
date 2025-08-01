//
//  LogViewer.swift
//  mi-parada
//
//  Created by Basile on 03/07/2025.
//

import SwiftUI

struct LogViewer: View {
    @StateObject private var logger = Logger.shared
    @State private var logs: [String] = []
    @State private var selectedLogLevel: LogLevel? = nil
    @State private var searchText = ""
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter controls
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search logs...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Log level filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedLogLevel == nil) {
                                selectedLogLevel = nil
                            }
                            
                            ForEach(LogLevel.allCases, id: \.self) { level in
                                FilterChip(
                                    title: level.rawValue,
                                    isSelected: selectedLogLevel == level
                                ) {
                                    selectedLogLevel = level
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Logs list
                List {
                    ForEach(filteredLogs, id: \.self) { logEntry in
                        LogEntryView(logEntry: logEntry)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Refresh") {
                        loadLogs()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        showingClearAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Clear All Logs", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    logger.clearAllLogs()
                    loadLogs()
                }
            } message: {
                Text("This will permanently delete all log files. This action cannot be undone.")
            }
        }
        .onAppear {
            loadLogs()
        }
    }
    
    private var filteredLogs: [String] {
        var filtered = logs
        
        // Filter by log level
        if let selectedLevel = selectedLogLevel {
            filtered = filtered.filter { logEntry in
                logEntry.contains("[\(selectedLevel.rawValue)]")
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { logEntry in
                logEntry.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private func loadLogs() {
        logs = logger.getRecentLogs(limit: 500)
    }
}

// MARK: - Log Entry View
struct LogEntryView: View {
    let logEntry: String
    
    private var logLevel: LogLevel {
        if logEntry.contains("[ERROR]") {
            return .error
        } else if logEntry.contains("[WARNING]") {
            return .warning
        } else if logEntry.contains("[INFO]") {
            return .info
        } else {
            return .debug
        }
    }
    
    private var backgroundColor: Color {
        switch logLevel {
        case .error:
            return Color.red.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .info:
            return Color.blue.opacity(0.1)
        case .debug:
            return Color.gray.opacity(0.1)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(logEntry)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(backgroundColor)
        .cornerRadius(6)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    LogViewer()
} 