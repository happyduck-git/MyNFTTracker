//
//  LoginViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import SnapKit
import Combine
import metamask_ios_sdk

final class LoginViewController: BaseViewController {
    
    // Firestore
    private let firestoreManager = FirestoreManager.shared
    
    // Metamask
    private let appMetadata = AppMetadata(name: "MyNFTTracker", url: "https://my-nft-tracker.com")
    
    // Combine
    private var bindings = Set<AnyCancellable>()
    
    // ViewModel
    private var vm: LoginViewViewModel
    
    //MARK: - UI Properties
    private let loadingVC = LoadingViewController()
    
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
        btn.titleLabel?.font = .appFont(name: .appMainFontBold, size: .head)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2.0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let signupButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(String(localized: "회원가입 하기"), for: .normal)
        btn.titleLabel?.font = .appFont(name: .appMainFontBold, size: .light)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    //MARK: - Init
    init(vm: LoginViewViewModel) {
        self.vm = vm
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateTheme()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bind()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
    }
    
}

extension LoginViewController {
    
    private func bind() {
        let metamask = MetaMaskSDK.shared(self.appMetadata)
        
        self.loginButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
            
                self.addChildViewController(self.loadingVC)
                
                Task {
                    let result = await metamask.connect()
                    switch result {
                    case .success(let adress):
                        self.saveWalletAddress(address: adress)
                        self.vm.walletConnected = true
                        
                        if metamask.connected {
                            print("Metamask connected")
                        } else {
                            print("Metamask NOT connected")
                        }
                        
                    case .failure(let error):
                        self.showWalletConnectiontFailedAlert()
                        AppLogger.logger.error("Connection error: \(String(describing: error))")
                    }
                    DispatchQueue.main.async {
                        self.loadingVC.removeViewController()
                    }
                }
                
            }
            .store(in: &bindings)
        
        self.vm.$walletConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let `self` = self else { return }
                
                if connected {
                   
                    Task {
                        guard let wallet = self.retrieveWalletAddress() else { return }
                        do {
                            self.vm.isFirstVisit = try await !self.firestoreManager.isRegisteredUser(wallet) ? true : false
                        }
                        catch {
                            AppLogger.logger.error("Error: \(error)")
                        }
                    }
                }
                
            }.store(in: &bindings)
        
        self.vm.$isFirstVisit
            .sink { [weak self] in
                
                guard let `self` = self,
                      let wallet = self.retrieveWalletAddress()
                else { return }
                /*
                let vc = MainViewController(vm: MainViewViewModel())
                self.show(vc, sender: self)
                 */
                if $0 {
                    Task {
                        try await self.firestoreManager.saveWalletAddress(wallet)
                        AppLogger.logger.info("New wallet \(wallet) has been registred.")
                        //TODO: Add Register nickname and profile picture.
                        DispatchQueue.main.async {
                            let registerVM = RegisterViewViewModel(walletAddres: wallet)
                            let registerVC = RegisterViewController(vm: registerVM)
                            
                            self.show(registerVC, sender: self)
                        }
                    }
                    
                } else {
                    
                }
            }
            .store(in: &bindings)
        
        self.signupButton.tapPublisher
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                metamask.clearSession()
            }
            .store(in: &bindings)
    }
    
}

extension LoginViewController {
    
    private func setUI() {
        self.view.addSubviews(self.logo,
                              self.loginButton,
                              self.signupButton)
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
        
        self.signupButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }

}

// MARK: - Wallet address
extension LoginViewController {
    
    private func saveWalletAddress(address: String?) {
        UserDefaults.standard.set(address, forKey: UserDefaultsConstants.walletAddress)
    }
    
    private func retrieveWalletAddress() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress)
    }
    
    private func showWalletConnectiontFailedAlert() {
        self.showAlert(alertTitle: "지갑 연결 실패",
                       alertMessage: "다시 한번 시도해주세요.",
                       alertStyle: .alert,
                       actionTitle1: "확인",
                       actionStyle1: .cancel)
    }
}

extension LoginViewController: BaseViewControllerDelegate {
    func firstBtnTapped() {
        return
    }
    
    func secondBtnTapped() {
        return
    }
    
    func themeChanged(as theme: Theme) {
        var gradientUpperColor: UIColor?
        var gradientLowerColor: UIColor?
        var buttonColor: UIColor?
        var borderColor: UIColor?
        var textColor: UIColor?
        
        switch theme {
        case .black:
            gradientUpperColor = AppColors.DarkMode.gradientUpper
            gradientLowerColor = AppColors.DarkMode.gradientLower
            buttonColor = AppColors.DarkMode.buttonActive
            borderColor = AppColors.DarkMode.border
            textColor = AppColors.DarkMode.text
        case .white:
            gradientUpperColor = AppColors.LightMode.gradientUpper
            gradientLowerColor = AppColors.LightMode.gradientLower
            buttonColor = AppColors.LightMode.buttonActive
            borderColor = AppColors.LightMode.border
            textColor = AppColors.LightMode.text
        }
        
        let gradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                                                  colors: [gradientUpperColor!,
                                                           gradientLowerColor!])
        self.view.backgroundColor = UIColor(patternImage: gradientImage)
        self.loginButton.backgroundColor = buttonColor
        self.loginButton.layer.borderColor = borderColor?.cgColor
        self.loginButton.setTitleColor(textColor, for: .normal)
    }
    
    
}

extension LoginViewController {
    private func updateTheme() {
        guard let themeString = UserDefaults.standard.string(forKey: UserDefaultsConstants.theme),
              let theme = Theme(rawValue: themeString)
        else {
            self.themeChanged(as: .black)
            return
        }
        
        self.themeChanged(as: theme)
    }
}
