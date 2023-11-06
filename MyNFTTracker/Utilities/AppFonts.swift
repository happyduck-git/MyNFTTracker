//
//  AppFonts.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit.UIFont

extension UIFont {

    enum AppFonts: String {
        case appMainFontBold = "DNFForgedBlade-Bold"
        case appMainFontMedium = "DNFForgedBlade-Medium"
        case appMainFontLight = "DNFForgedBlade-Light"
    }
    
    static func appFont(name: AppFonts, size: CGFloat) -> UIFont? {
        return UIFont(name: name.rawValue, size: size)
    }
}
