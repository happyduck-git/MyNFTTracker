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
    
    enum AppFontSize: CGFloat {
        case light = 12
        case plain = 14
        case main = 15
        case title = 17
        case head = 20
        case big = 40
    }
    
    static func appFont(name: AppFonts, size: AppFontSize) -> UIFont? {
        return UIFont(name: name.rawValue, size: size.rawValue)
    }
}
