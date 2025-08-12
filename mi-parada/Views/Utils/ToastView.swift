//
//  ToastView.swift
//  mi-parada
//
//  Created by Basile on 12/08/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .bold()
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct ToastContainer<Content: View>: View {
    @EnvironmentObject var toastManager: ToastManager
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .environmentObject(toastManager)
            
            if toastManager.isVisible {
                VStack {
                    Spacer()
                    ToastView(message: toastManager.message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                }
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: toastManager.isVisible)
    }
}
