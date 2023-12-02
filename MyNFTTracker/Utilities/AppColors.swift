//
//  AppColors.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit.UIColor

enum AppColors {
    
    enum LightMode {
        static let gradientUpper = UIColor(hex: 0xF3C1EB)
        static let gradientLower = UIColor(hex: 0xFFE5CC)
        static let buttonActive = UIColor(hex: 0xF4D2A0)
        static let buttonInactive = UIColor.darkGray
        static let border = UIColor(hex: 0xFFFFFF)
        static let text = UIColor(hex: 0x0D0D0D)
    }
    
    enum DarkMode {
        static let gradientUpper = UIColor(hex: 0x0E1448)
        static let gradientLower = UIColor(hex: 0x6F431A)
        static let buttonActive = UIColor(hex: 0x1E1D1A)
        static let buttonInactive = UIColor.darkGray
        static let border = UIColor(hex: 0x0D0D0D)
        static let text = UIColor(hex: 0xFAE9CF)
    }
    
    static let frameGradientMint = UIColor(hex: 0x65C6C0)
    static let frameGradientPurple = UIColor(hex: 0xBF70E5)
    
}
