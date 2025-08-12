//
//  ToastManager.swift
//  mi-parada
//
//  Created by Basile on 12/08/2025.
//

import SwiftUI
import Combine

class ToastManager: ObservableObject {
    @Published var message: String = ""
    @Published var isVisible: Bool = false
    
    func show(message: String, duration: TimeInterval = 3) {
        logger.info("toast" + " \(message)")
        self.message = message
        withAnimation {
            self.isVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isVisible = false
            }
        }
    }
}
