//
//  UIView+Extensions.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit.UIView

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

extension UIView {
    func setGradientBorder() {
        let gradient = UIImage.gradientImage(bounds: self.bounds,
                                             colors: [AppColors.frameGradientPurple,
                                                      AppColors.frameGradientMint,
                                                      .black],
                                             startPoint: CGPoint(x: 1.0, y: 0.0),
                                             endPoint: CGPoint(x: 0.0, y: 1.0))
        let graidentColor = UIColor(patternImage: gradient)
        self.layer.borderColor = graidentColor.cgColor
    }
}
