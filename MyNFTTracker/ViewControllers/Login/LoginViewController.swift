//
//  LoginViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import SnapKit
import Combine

final class LoginViewController: UIViewController {
    
    private let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .myNFTTrackerLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(String(localized: "Metamask로 로그인"), for: .normal)
        btn.titleLabel?.font = .appFont(name: .appMainFontBold, size: 18)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2.0
        btn.backgroundColor = AppColors.buttonBeige
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                              colors: [AppColors.gradientPink,
                                       AppColors.gradientGreen])
        view.backgroundColor = UIColor(patternImage: gradientImage)
        
        self.setUI()
        self.setLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
    }
    
}

extension LoginViewController {
    
    private func setUI() {
        self.view.addSubviews(self.logo,
                              self.loginButton)
    }
    
    private func setLayout() {
        self.logo.snp.makeConstraints {
            $0.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.loginButton.snp.makeConstraints {
            $0.top.equalTo(self.logo.snp.bottom).offset(40)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
        
    }

}
