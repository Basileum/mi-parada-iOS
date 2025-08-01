//
//  BackgroundPointMap.swift
//  mi-parada
//
//  Created by Basile on 21/07/2025.
//

import SwiftUI

struct BackgroundPointMap{
                                
    static func imageWithBackground(image: UIImage, backgroundColor: UIColor, size: CGSize? = nil) -> UIImage {
        let finalSize = size ?? image.size
        let renderer = UIGraphicsImageRenderer(size: finalSize)
        
        return renderer.image { context in
            // Fill background
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: finalSize))
            
            // Draw image centered
            let imageRect = CGRect(
                x: (finalSize.width - image.size.width) / 2,
                y: (finalSize.height - image.size.height) / 2,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: imageRect)
        }
    }

}
