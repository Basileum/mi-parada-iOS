//
//  ToggleButton.swift
//  mi-parada
//
//  Created by Basile on 10/07/2025.
//

import SwiftUI

struct ToggleBtn: View {
    
    @Binding var isMapMode: Bool
    @State var leftName: String
    @State var rightName : String
    
    
    var body: some View {
            ZStack{
                Capsule()
                    .fill(.blue)
                    .stroke(isMapMode ? .gray : .black,lineWidth: 3)
                    .frame(width: 200,height: 50)
                HStack{
                    ZStack{
                        Capsule()
                            .fill(.yellow)
                            .frame(width: 93,height: 48)
                            .onTapGesture {
                                isMapMode.toggle();
                                print(isMapMode)
                            }
                            .offset(x: isMapMode ? 107 : 0)
                            //.withAanimation(.easeOut(duration: 0.5))
                        
                        Text("\(leftName)")
                    }
                    ZStack{
                        Capsule()
                            .fill(.clear)
                            .frame(width: 98,height: 48)
                        Text("\(rightName)")
                    }
                }
            }
    }
}

#Preview {
    ToggleBtn(isMapMode : .constant(false),leftName: "Map", rightName: "Lines")
}

