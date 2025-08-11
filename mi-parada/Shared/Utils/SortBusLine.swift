//
//  SortBusLine.swift
//  mi-parada
//
//  Created by Basile on 11/08/2025.
//

extension String {
    func splitPrefixAndNumber() -> (prefix: String, number: Int, originalNumber: String) {
        var prefix = ""
        var digits = ""
        for char in self {
            if char.isNumber {
                digits.append(char)
            } else if digits.isEmpty {
                prefix.append(char)
            } else {
                prefix.append(char)
            }
        }
        return (
            prefix: prefix.uppercased(),
            number: Int(digits) ?? Int.max,
            originalNumber: digits
        )
    }
}

extension Array where Element == NearStopLine {
    func sortedByBusLineLabel() -> [NearStopLine] {
        return self.sorted { a, b in
            let pa = a.label.splitPrefixAndNumber()
            let pb = b.label.splitPrefixAndNumber()
            
            let isANight = pa.prefix == "N"
            let isBNight = pb.prefix == "N"
            if isANight != isBNight {
                return !isANight && isBNight
            }
            
            if pa.prefix != pb.prefix {
                return pa.prefix < pb.prefix
            } else if pa.number != pb.number {
                return pa.number < pb.number
            } else {
                return pa.originalNumber.count > pb.originalNumber.count
            }
        }
    }
}

extension Array where Element == GroupedArrival {
    func sortedByBusLineLabel() -> [GroupedArrival] {
        return self.sorted { a, b in
            let pa = a.line.splitPrefixAndNumber()
            let pb = b.line.splitPrefixAndNumber()
            
            let isANight = pa.prefix == "N"
            let isBNight = pb.prefix == "N"
            if isANight != isBNight {
                return !isANight && isBNight
            }
            
            if pa.prefix != pb.prefix {
                return pa.prefix < pb.prefix
            } else if pa.number != pb.number {
                return pa.number < pb.number
            } else {
                return pa.originalNumber.count > pb.originalNumber.count
            }
        }
    }
}

extension Array where Element == BusArrival {
    func sortedByBusLineLabel() -> [BusArrival] {
        return self.sorted { a, b in
            let pa = a.line.splitPrefixAndNumber()
            let pb = b.line.splitPrefixAndNumber()
            
            let isANight = pa.prefix == "N"
            let isBNight = pb.prefix == "N"
            if isANight != isBNight {
                return !isANight && isBNight
            }
            
            if pa.prefix != pb.prefix {
                return pa.prefix < pb.prefix
            } else if pa.number != pb.number {
                return pa.number < pb.number
            } else {
                return pa.originalNumber.count > pb.originalNumber.count
            }
        }
    }
}

func sortBusLineLabels(_ labels: [String]) -> [String] {
    return labels.sorted { a, b in
        let pa = a.splitPrefixAndNumber()
        let pb = b.splitPrefixAndNumber()
        
        let isANight = pa.prefix == "N"
        let isBNight = pb.prefix == "N"
        if isANight != isBNight {
            return !isANight && isBNight
        }
        if pa.prefix != pb.prefix {
            return pa.prefix < pb.prefix
        } else if pa.number != pb.number {
            return pa.number < pb.number
        } else {
            return pa.originalNumber.count > pb.originalNumber.count
        }
    }
}
