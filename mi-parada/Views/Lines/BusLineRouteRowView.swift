//
//  BusLineRouteRowView.swift
//  mi-parada
//
//  Created by Basile on 29/07/2025.
//

import SwiftUI

struct BusLineRouteRowView: View {
    let stop: BusStop
    let isFirst: Bool
    let isLast: Bool
//    let zoomEnabled: Bool
//    
//    let scrollOffset: CGFloat
//    let scrollViewHeight: CGFloat


    var body: some View {

//        GeometryReader { geo in
//            let rowMidY = geo.frame(in: .named("scroll")).midY
//            let visibleCenterY = 200.0
//            let distance = abs(rowMidY - visibleCenterY)
//            let scale = zoomEnabled ? max(1.0, 1.3 - distance / 200) : 1.0
//            
//            let _ = Self.debugLog(busStop:stop, rowMidY: rowMidY, visibleCenterY: visibleCenterY, distance: distance, scale: scale, scrollOffset:scrollOffset, scrollViewHeight:scrollViewHeight)


            
            NavigationLink(value: stop) {
                HStack(alignment: .center, spacing: 8) {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(isFirst ? .clear : Color.blue)
                            .frame(width: 5, height: 12)

                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 12, height: 12)

                        Rectangle()
                            .fill(isLast ? .clear : Color.blue)
                            .frame(width: 5, height: 12)
                    }

                    Text(stop.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()
                }
                .background(Color.white)
                //.cornerRadius(12)
                //.shadow(radius: 2)
                //.scaleEffect(x:1.0, y:scale)
                //.scaleEffect(scale)
                //.animation(.easeInOut(duration: 0.25), value: scale)
            
        }
            //.frame(height:36)
            //.background(Color.red.opacity(0.1))
            //.buttonStyle(PlainButtonStyle())
    }
    
    static func debugLog(busStop:BusStop, rowMidY: CGFloat, visibleCenterY: CGFloat, distance: CGFloat, scale: CGFloat, scrollOffset:CGFloat, scrollViewHeight:CGFloat) -> Bool {
        print("stop: \(busStop.name), rowMidY: \(rowMidY), visibleCenterY: \(visibleCenterY), distance: \(distance), scale: \(scale)")
        print("scrollOffset : \(scrollOffset), scrollViewHeight : \(scrollViewHeight) ")
        return true // just to allow inline usage
    }
}

