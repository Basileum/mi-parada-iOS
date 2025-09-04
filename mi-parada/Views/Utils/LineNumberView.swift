//
//  LineNumberView.swift
//  mi-parada
//
//  Created by Basile on 20/07/2025.
//

import SwiftUI

struct LineNumberView: View {
    let busLine : BusLine
    
    var body: some View {
        VStack{
            Text(busLine.label)
                .foregroundColor(Color(hex:busLine.colorForeground))
                .font(.headline)
                .padding(.horizontal)
                
        }
        .frame(/*width:70,*/height: 20)
        .background(Color(hex:busLine.colorBackground))
        .cornerRadius(5)
    }
}

//#Preview {
//    LineNumberView(busLine: BusLine(
//        label: "24",
//        externalFrom: "from",
//        externalTo: "to",
//        colorBackground: "#00aecf",
//        colorForeground: "#ffffff"))
//    
//    LineNumberView(busLine: BusLine(
//        label: "C02",
//        externalFrom: "from",
//        externalTo: "to",
//        colorBackground: "#00aecf",
//        colorForeground: "#ffffff"))
//    
//    LineNumberView(busLine: BusLine(
//        label: "001",
//        externalFrom: "from",
//        externalTo: "to",
//        colorBackground: "#00aecf",
//        colorForeground: "#ffffff"))
//}
