//
//  UIImage+Extensions.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit.UIImage

extension UIImage {
    static func gradientImage(bounds: CGRect,
                              colors: [UIColor],
                              startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
                              endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0))
    -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
