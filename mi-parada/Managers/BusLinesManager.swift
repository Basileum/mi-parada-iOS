//
//  FavoritesManager.swift
//  mi-parada
//
//  Created by Basile on 17/07/2025.
//
import Foundation

@MainActor
class BusLinesManager: ObservableObject {
    static let shared = BusLinesManager()
    
    @Published private(set) var busLines: [String : BusLine] = [:]
    private(set) var busLinesByLabel: [String : BusLine] = [:]

    private let storageKey = "busLines"

    init() {
        logger.info("BusLinesManager: Initializing bus lines manager")
        loadBusLines()
        logger.info("BusLinesManager: Loaded \(busLines.count) bus lines")
    }
    
    @MainActor
    func storeBusLines(busLines : [BusLine]) async {
        logger.info("BusLinesManager: Storing \(busLines.count) bus lines")
        self.busLines = [:]
        for busLine in busLines {
            self.busLines[busLine.id] = busLine
            self.busLinesByLabel[busLine.label] = busLine
        }
        logger.debug("BusLinesManager: Bus lines stored: \(self.busLines)")
        logger.debug("BusLinesManager: Bus lines by label stored: \(self.busLinesByLabel)")
        saveBusLines()
    }
    
    func getBusLine(id: String) -> BusLine? {
        let busLine = busLines[id]
        logger.debug("BusLinesManager: Getting bus line with ID \(id): \(busLine?.label ?? "not found")")
        return busLine
    }
    
    func getBusLineByLabel(label: String) -> BusLine? {
        logger.debug(label)
        let busLine = busLinesByLabel[label]
        logger.debug("BusLinesManager: Getting bus line with Label \(label): \(busLine?.id ?? "not found")")
        return busLine
    }
    
    private func loadBusLines() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String : BusLine].self, from: data) {
            self.busLines = decoded
            logger.debug("BusLinesManager: Successfully loaded \(decoded.count) bus lines from storage")
        } else {
            logger.debug("BusLinesManager: No saved bus lines found or failed to decode")
        }
    }
    
    private func saveBusLines() {
        if let data = try? JSONEncoder().encode(busLines) {
            UserDefaults.standard.set(data, forKey: storageKey)
            logger.debug("BusLinesManager: Saved \(busLines.count) bus lines to storage")
        } else {
            logger.error("BusLinesManager: Failed to encode bus lines for saving")
        }
    }

}
