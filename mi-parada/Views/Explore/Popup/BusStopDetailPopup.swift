//
//  BusStopDetailPopup.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI
import MapKit

struct BusStopDetailPopup: View {
    let stop: NearStopData
    @Binding var isPresented: Bool
    @EnvironmentObject var favorites: FavoritesManager
    @State private var selectedTab = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showingWatchSelection = false
    @EnvironmentObject var nav: NavigationCoordinator



    
    // Navigation callback to handle bus line selection
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stop.stopName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 12) {
//                        // Favorite button
//                        Button(action: {
//                            logger.info("BusStopDetailPopup: User toggled favorite for stop \(stop.stopName)")
//                            favorites.toggle(FavoritesBusStop(stop: stop, busLines: [line]))
//                        }) {
//                            Image(systemName: isFavorite ? "star.fill" : "star")
//                                .font(.title2)
//                                .foregroundColor(isFavorite ? .yellow : .secondary)
//                        }
                        
                        // Watch button
                        Button(action: {
                            logger.info("BusStopDetailPopup: User tapped watch button for stop \(stop.stopName)")
                            showingWatchSelection = true
                        }) {
                            Image(systemName: "binoculars.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // Close button
                        Button(action: {
                            logger.info("BusStopDetailPopup: User closed popup for stop \(stop.stopName)")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Distance info
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("\(stop.metersToPoint) meters away")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Divider()
                .padding(.vertical, 12)
            
            // Tab selector
//            HStack(spacing: 0) {
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        logger.debug("BusStopDetailPopup: User switched to Next Bus tab")
//                        selectedTab = 0
//                    }
//                }) {
//                    VStack(spacing: 4) {
//                        Image(systemName: "bus.fill")
//                            .font(.system(size: 16))
//                        Text("Next Buses")
//                            .font(.caption)
//                    }
//                    .foregroundColor(selectedTab == 0 ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                    //.padding(.vertical, 12)
//                }
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        logger.debug("BusStopDetailPopup: User switched to Next Bus tab")
//                        selectedTab = 1
//                    }
//                }) {
//                    VStack(spacing: 4) {
//                        Image(systemName: "bus.fill")
//                            .font(.system(size: 16))
//                        Text("Next Buses")
//                            .font(.caption)
//                    }
//                    .foregroundColor(selectedTab == 1 ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                    //.padding(.vertical, 12)
//                }
//            }
            HStack(spacing: 2) {
                TabButton(
                    image: Image(systemName: "bus.fill"),
                    title: "Next Bus",
                    isSelected: selectedTab == 0,
                    action: {
                        logger.debug("BusStopDetailPopup: User switched to Next Bus tab")
                        selectedTab = 0
                    }
                )
                
                TabButton(
                    image: Image(systemName: "info.square"),
                    title: "Info",
                    isSelected: selectedTab == 1,
                    action: {
                        logger.debug("BusStopDetailPopup: User switched to Info tab")
                        selectedTab = 1
                    }
                )
            }
            //.padding(.horizontal, 20)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5).opacity(0.8)) // Adaptive color for light/dark
            )
            .padding(.horizontal, 20)
            
            // Tab content
            TabView(selection: $selectedTab) {
                NextBusTabView(stop: stop, onBusLineSelected: onBusLineSelected)
                    .tag(0)
                
                InfoTabView(stop: stop, onBusLineSelected: onBusLineSelected)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 200 + dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    // Only allow downward dragging
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    isDragging = false
                    // If dragged down more than 100 points, close the popup
                    if value.translation.height > 100 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    } else {
                        // Snap back to original position
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .sheet(isPresented: $showingWatchSelection) {
            WatchSelectionView(stop: stop, onBusLineSelected: onBusLineSelected)
        }
    }
    
    
    
    // MARK: - Computed Properties
    private var isFavorite: Bool {
        let busStop = BusStop(
            id: stop.stopId,
            name: stop.stopName,
            coordinate: Coordinate(stop.coordinate)
        )
        let favoriteStop = FavoritesBusStop(
            stop: busStop,
            busLines: Set(stop.lines.map { line in
                BusLine(
                    label: line.label,
                    externalFrom: line.nameA,
                    externalTo: line.nameB,
                    colorBackground: "#00aecf",
                    colorForeground: "#ffffff"
                )
            })
        )
        return favorites.isFavorite(favoriteStop)
    }
    
    // MARK: - Helper Functions
    private func toggleFavorite() {
        let busStop = BusStop(
            id: stop.stopId,
            name: stop.stopName,
            coordinate: Coordinate(stop.coordinate)
        )
        let favoriteStop = FavoritesBusStop(
            stop: busStop,
            busLines: Set(stop.lines.map { line in
                BusLine(
                    label: line.label,
                    externalFrom: line.nameA,
                    externalTo: line.nameB,
                    colorBackground: "#00aecf",
                    colorForeground: "#ffffff"
                )
            })
        )
        favorites.toggle(favoriteStop)
        
        
    }
}

// MARK: - Bus Line Item View
struct BusLineItemView: View {
    let line: NearStopLine
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    @EnvironmentObject var nav: NavigationCoordinator

    
    var body: some View {
        // Convert NearStopLine to BusLine for LineNumberView
        var busLine: BusLine {
            BusLine(
                label: line.label,
                externalFrom: line.nameA,
                externalTo: line.nameB,
                colorBackground: "#00aecf",
                colorForeground: "#ffffff"
            )
        }
        
        HStack(spacing: 12) {
            // Line number with fixed width for alignment
            LineNumberView(busLine: busLine)
                .frame(width: 70, alignment: .center)
            
            // Destination name based on "to" attribute
            Text(destinationName)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 6)
        .onTapGesture {
            logger.info("BusStopDetailPopup: User tapped on bus line \(line.label)")
            let busLine = BusLine(
                label: line.label,
                externalFrom: line.nameA,
                externalTo: line.nameB,
                colorBackground: "#00aecf",
                colorForeground: "#ffffff"
            )
            nav.selectedBusLine = busLine
            nav.selectedTab = 1
        }
    }
    
    private var destinationName: String {
        switch line.to {
        case "A":
            return line.nameA
        case "B":
            return line.nameB
        default:
            return line.nameA // Default to nameA if "to" is not A or B
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let image: Image
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                image.font(.system(size: 16))
                Text(title)
                    .font(.caption)
            }
            //.fontWeight(isSelected ? .semibold : .medium)
            
            .foregroundColor(isSelected ? .blue : .secondary)
            .padding(.vertical, 2)
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? tabBackgroundColor : Color.clear)
                    .shadow(color: isSelected ? shadowColor : .clear, radius: 3, x: 0, y: 2)
            )
            .padding(3)
//            .background(
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(isSelected ? Color.white : Color.clear)
//                    .shadow(color: isSelected ? .black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
//            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // Light & dark mode adaptive colors
    var tabBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray3) : Color.white
    }
    
    var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.15)
    }
}


// MARK: - Grouped Arrival Model
struct GroupedArrival: Identifiable {
    let line: String
    let destination: String
    let times: String
    
    var id: String { "\(line)_\(destination)" }
}

// MARK: - Grouped Arrival Row View
struct GroupedArrivalRowView: View {
    let groupedArrival: GroupedArrival
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    @EnvironmentObject var nav: NavigationCoordinator

    
    var body: some View {
        HStack(spacing: 0) {
            // Line number
            HStack(spacing:0) {
                Spacer()

                LineNumberView(busLine: BusLine(
                    label: groupedArrival.line,
                    externalFrom: "",
                    externalTo: "",
                    colorBackground: "#00aecf",
                    colorForeground: "#ffffff"
                ))
                
                Spacer()

            }
            .frame(width: 85)
        
            
            
            
            VStack(alignment: .leading, spacing: 1) {
                Text(groupedArrival.destination)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Arrival times
            VStack(alignment: .trailing, spacing: 2) {
                Text(groupedArrival.times)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .frame(width: 120)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 3)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onTapGesture {
            logger.info("BusStopDetailPopup: User tapped on bus line \(groupedArrival.line)")
            let busLine = BusLine(
                label: groupedArrival.line,
                externalFrom: "",
                externalTo: "",
                colorBackground: "#00aecf",
                colorForeground: "#ffffff"
            )
            nav.selectedBusLine = busLine
            nav.selectedTab = 1
        }
    }
}

// MARK: - Arrival Row View
struct ArrivalRowView: View {
    let arrival: BusArrival
    
    var body: some View {
        HStack(spacing: 12) {
            // Line number
            LineNumberView(busLine: BusLine(
                label: arrival.line,
                externalFrom: "",
                externalTo: "",
                colorBackground: "#00aecf",
                colorForeground: "#ffffff"
            ))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(arrival.destination)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Arrival time
            VStack(alignment: .trailing, spacing: 2) {
                Text(ArrivalFormatsTime.simpleFormatArrivalTime(arrival.estimateArrive))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    BusStopDetailPopup(
        stop: NearStopData(
            stopId: 4096,
            geometry: StopGeometry(type: "Point", coordinates: [-3.702116076632696, 40.41994219776433]),
            stopName: "Metro Gran Vía",
            address: "Gran Vía, 25",
            metersToPoint: 0,
            lines: [
                NearStopLine(line: "362", label: "002", nameA: "PUERTA DE TOLEDO", nameB: "ARGÜELLES", metersFromHeader: 2360, to: "A"),
                NearStopLine(line: "361", label: "001", nameA: "ESTACION DE ATOCHA", nameB: "MONCLOA", metersFromHeader: 2509, to: "B")
            ]
        ),
        isPresented: .constant(true)
    )
}

