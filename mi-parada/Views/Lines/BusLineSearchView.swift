import SwiftUI

struct BusLineSearchView: View {
    @State private var searchText = ""
    @State private var busLines: [BusLine] = []
    @State private var isLoading = true
    @State private var selectedBusLine: BusLine?
    
    @EnvironmentObject var nav: NavigationCoordinator
    @State private var path = NavigationPath()

    
    // Optional parameter to pre-select a bus line
    var preselectedBusLine: BusLine? = nil

    var filteredBusLines: [BusLine] {
        if searchText.isEmpty {
            return busLines
        } else {
            return busLines.filter {
                $0.label.localizedCaseInsensitiveContains(searchText) ||
                $0.externalFrom.localizedCaseInsensitiveContains(searchText) ||
                $0.externalTo.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
            NavigationStack(path: $path) {
                List {
                    TextField("Search a bus line...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical)

                    if isLoading {
                        ProgressView("Loading...")
                    } else {
                        ForEach(filteredBusLines) { line in
                            NavigationLink(value: line) {
                                HStack {
                                    LineNumberView(busLine: line)
                                    Spacer()
                                    VStack {
                                        Text(line.externalFrom)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(line.externalTo)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select a Bus Line")
                .navigationDestination(for: BusLine.self) { line in
                    BusLineDetailView(busLine: line, path:$path)
                }
                .navigationDestination(for: BusStop.self) { stop in
                    StopDetailView(stop: stop)
                }
            }
            .onChange(of: nav.selectedBusLine) { newValue in
                if let line = newValue {
                    path.append(line)
                    nav.selectedBusLine = nil
                }
            }
            .onAppear {
                if let preselected = selectedBusLine {
                    path.append(preselected) // Go directly to this line
                }
                else {
                    loadBusLines()
                }
            }
        }
    

    func loadBusLines() {
        BusLineService.fetchBusLines { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lines):
                    self.busLines = lines
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
}
