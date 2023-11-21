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
    func setGradientBorder(
        colors: [UIColor],
        startPoint: CGPoint,
        endPoint: CGPoint,
        borderWidth: CGFloat
    ) {
        let gradient = UIImage.gradientImage(bounds: self.bounds,
                                             colors: colors,
                                             startPoint: startPoint,
                                             endPoint: endPoint)
        let graidentColor = UIColor(patternImage: gradient)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = graidentColor.cgColor
    }
}

extension UIView {
    func circleView() {
        if self.frame.width.isEqual(to: self.frame.height) {
            self.layer.cornerRadius = self.frame.width / 2
        }
    }
}
