//
//  AppColors.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit.UIColor

protocol ColorSet {
    static var gradientUpper: UIColor { get }
    static var gradientLower: UIColor { get }
    static var buttonActive: UIColor { get }
    static var buttonInactive: UIColor { get }
    static var border: UIColor { get }
    static var text: UIColor { get }
    static var secondaryBackground: UIColor { get }
}

enum AppColors {
    
    enum LightMode: ColorSet {
        static let gradientUpper = UIColor(hex: 0xF3C1EB)
        static let gradientLower = UIColor(hex: 0xFFE5CC)
        static let buttonActive = UIColor(hex: 0xEA9CCB)
        static let buttonInactive = UIColor.darkGray
        static let border = UIColor(hex: 0xFFFFFF)
        static let text = UIColor(hex: 0x0D0D0D)
        static let secondaryText = UIColor(hex: 0x605E5E)
        static let secondaryBackground = UIColor(hex: 0xFDFCF1)
    }
    
    enum DarkMode: ColorSet {
        static let gradientUpper = UIColor(hex: 0x0E1448)
        static let gradientLower = UIColor(hex: 0x6F431A)
        static let buttonActive = UIColor(hex: 0x4461CA)
        static let buttonInactive = UIColor.darkGray
        static let border = UIColor(hex: 0x0D0D0D)
        static let text = UIColor(hex: 0xFAE9CF)
        static let secondaryText = UIColor(hex: 0xC1AA95)
        static let secondaryBackground = UIColor(hex: 0x08061C)
    }
    
    static let frameGradientMint = UIColor(hex: 0x65C6C0)
    static let frameGradientPurple = UIColor(hex: 0xBF70E5)
    static let selectedBorder = UIColor(hex: 0x5DD1EB)
}
