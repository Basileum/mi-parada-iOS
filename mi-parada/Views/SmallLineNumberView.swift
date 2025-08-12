//
//  LineNumberView.swift
//  mi-parada
//
//  Created by Basile on 20/07/2025.
//

import SwiftUI

struct SmallLineNumberView: View {
    let busLine : BusLine
    
    var body: some View {
        VStack{
            Text(busLine.label)
                .foregroundColor(Color(hex:busLine.colorForeground))
                .font(.system(size: 12))
                .padding(.horizontal)
                
        }
        .frame(/*width:80,*/height: 20)
        .background(Color(hex:busLine.colorBackground))
        .cornerRadius(5)
    }
}


#Preview {
    SmallLineNumberView(busLine: BusLine(
        label: "24",
        externalFrom: "from",
        externalTo: "to",
        colorBackground: "#00aecf",
        colorForeground: "#ffffff"
    ))
    
    SmallLineNumberView(busLine: BusLine(
        label: "C02",
        externalFrom: "from",
        externalTo: "to",
        colorBackground: "#00aecf",
        colorForeground: "#ffffff"))
    
    SmallLineNumberView(busLine: BusLine(
        label: "001",
        externalFrom: "from",
        externalTo: "to",
        colorBackground: "#00aecf",
        colorForeground: "#ffffff"))
}
