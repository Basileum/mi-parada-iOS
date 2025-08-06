//
//  Logger.swift
//  mi-parada
//
//  Created by Basile on 03/07/2025.
//

import Foundation
import os.log

// MARK: - Log Levels
enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var emoji: String {
        switch self {
        case .debug: return ""
        case .info: return ""
        case .warning: return ""
        case .error: return ""
        }
    }
    
    var priority: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        }
    }
}

// MARK: - Logger Configuration
struct LoggerConfig {
    static let maxLogFiles = 10 // Keep 10 days of logs
    static let logDirectoryName = "Logs"
    static let logFilePrefix = "mi-parada"
    static let logFileExtension = "log"
    static let maxFileSize = 10 * 1024 * 1024 // 10MB per file
}

// MARK: - Main Logger Class
class Logger: ObservableObject {
    static let shared = Logger()
    
    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter
    private let logQueue = DispatchQueue(label: "com.mi-parada.logger", qos: .utility)
    
    private var currentLogFile: URL?
    private var currentLogFileHandle: FileHandle?
    
    // Only logs with a level >= this threshold will be written
    private let logLevelThreshold: LogLevel
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        #if DEBUG_LOGGING
        logLevelThreshold = .debug
        print("✅ DEBUG_LOGGING flag is ENABLED")
        #else
        logLevelThreshold = .info
        print("❌ DEBUG_LOGGING flag is DISABLED")
        #endif
        
        setupLogDirectory()
        rotateLogFilesIfNeeded()
        openCurrentLogFile()
    }
    
    deinit {
        closeCurrentLogFile()
    }
    
    // MARK: - Public Logging Methods
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message: message, file: file, function: function, line: line)
    }
    
    func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message: "Error: \(error.localizedDescription)", file: file, function: function, line: line)
    }
    
    // MARK: - Private Logging Implementation
    
    private func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard level.priority >= logLevelThreshold.priority else {
            return
        }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)\n"
        
        // Console logging
        print(logMessage, terminator: "")
        
        // File logging
        logQueue.async {
            self.writeToFile(logMessage)
        }
    }
    
    // MARK: - File Management
    
    private func setupLogDirectory() {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Logger: Could not access documents directory")
            return
        }
        
        let logsDirectory = documentsPath.appendingPathComponent(LoggerConfig.logDirectoryName)
        
        do {
            if !fileManager.fileExists(atPath: logsDirectory.path) {
                try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
                print("✅ Logger: Created logs directory at \(logsDirectory.path)")
            }
        } catch {
            print("❌ Logger: Failed to create logs directory: \(error)")
        }
    }
    
    private func getLogsDirectory() -> URL? {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsPath.appendingPathComponent(LoggerConfig.logDirectoryName)
    }
    
    private func getCurrentLogFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return "\(LoggerConfig.logFilePrefix)-\(dateString).\(LoggerConfig.logFileExtension)"
    }
    
    private func openCurrentLogFile() {
        guard let logsDirectory = getLogsDirectory() else { return }
        
        let fileName = getCurrentLogFileName()
        let logFileURL = logsDirectory.appendingPathComponent(fileName)
        
        do {
            if !fileManager.fileExists(atPath: logFileURL.path) {
                try "".write(to: logFileURL, atomically: true, encoding: .utf8)
            }
            
            currentLogFile = logFileURL
            currentLogFileHandle = try FileHandle(forWritingTo: logFileURL)
            currentLogFileHandle?.seekToEndOfFile()
            
            // Log startup message
            let startupMessage = "Logger: Started logging to \(fileName)\n"
            currentLogFileHandle?.write(startupMessage.data(using: .utf8) ?? Data())
            
        } catch {
            print("❌ Logger: Failed to open log file: \(error)")
        }
    }
    
    private func closeCurrentLogFile() {
        currentLogFileHandle?.closeFile()
        currentLogFileHandle = nil
        currentLogFile = nil
    }
    
    private func writeToFile(_ message: String) {
        guard let fileHandle = currentLogFileHandle else {
            openCurrentLogFile()
            return
        }
        
        do {
            if let data = message.data(using: .utf8) {
                fileHandle.write(data)
                fileHandle.synchronizeFile()
                
                // Check if file size exceeds limit
                if let fileSize = try? fileHandle.seekToEnd() {
                    if fileSize > LoggerConfig.maxFileSize {
                        rotateLogFile()
                    }
                }
            }
        } catch {
            print("❌ Logger: Failed to write to log file: \(error)")
        }
    }
    
    private func rotateLogFile() {
        closeCurrentLogFile()
        openCurrentLogFile()
    }
    
    private func rotateLogFilesIfNeeded() {
        guard let logsDirectory = getLogsDirectory() else { return }
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey])
                .filter { $0.pathExtension == LoggerConfig.logFileExtension }
                .sorted { file1, file2 in
                    let date1 = try file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1 > date2
                }
            
            // Remove old log files beyond the limit
            if logFiles.count > LoggerConfig.maxLogFiles {
                let filesToRemove = Array(logFiles[LoggerConfig.maxLogFiles...])
                for file in filesToRemove {
                    try fileManager.removeItem(at: file)
                    print("Logger: Removed old log file: \(file.lastPathComponent)")
                }
            }
            
        } catch {
            print("❌ Logger: Failed to rotate log files: \(error)")
        }
    }
    
    // MARK: - Log Retrieval
    
    func getRecentLogs(limit: Int = 100) -> [String] {
        guard let logsDirectory = getLogsDirectory() else { return [] }
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey])
                .filter { $0.pathExtension == LoggerConfig.logFileExtension }
                .sorted { file1, file2 in
                    let date1 = try file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1 > date2
                }
            
            var allLogs: [String] = []
            
            for logFile in logFiles.prefix(3) { // Get last 3 days
                if let content = try? String(contentsOf: logFile) {
                    allLogs.append(contentsOf: content.components(separatedBy: .newlines))
                }
            }
            
            return Array(allLogs.suffix(limit))
            
        } catch {
            print("❌ Logger: Failed to retrieve logs: \(error)")
            return []
        }
    }
    
    func clearAllLogs() {
        guard let logsDirectory = getLogsDirectory() else { return }
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == LoggerConfig.logFileExtension }
            
            for file in logFiles {
                try fileManager.removeItem(at: file)
            }
            
            print("Logger: Cleared all log files")
            
        } catch {
            print("❌ Logger: Failed to clear logs: \(error)")
        }
    }
}

// MARK: - Convenience Extensions

extension Logger {
    // Network logging
    func logNetworkRequest(_ url: String, method: String, headers: [String: String]? = nil) {
        info("Network Request: \(method) \(url)")
        if let headers = headers {
            debug("Headers: \(headers)")
        }
    }
    
    func logNetworkResponse(_ url: String, statusCode: Int, responseTime: TimeInterval) {
        let statusIndicator = statusCode >= 200 && statusCode < 300 ? "SUCCESS" : "ERROR"
        info("Network Response: \(statusIndicator) \(statusCode) (\(String(format: "%.2f", responseTime))s) \(url)")
    }
    
    // Location logging
    func logLocationUpdate(_ latitude: Double, longitude: Double, accuracy: Double) {
        info("Location Update: (\(latitude), \(longitude)) accuracy: \(String(format: "%.1f", accuracy))m")
    }
    
    // Bus arrival logging
    func logBusArrival(_ stopId: Int, line: String, estimatedArrival: Int) {
        info("Bus Arrival: Line \(line) at stop \(stopId) in \(estimatedArrival)s")
    }
    
    // Live activity logging
    func logLiveActivity(_ action: String, stopId: Int, line: String) {
        info("Live Activity: \(action) for Line \(line) at stop \(stopId)")
    }
}

// MARK: - Global Logger Access

// Global logger instance for easy access
let logger = Logger.shared 
