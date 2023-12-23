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
import FirebaseFirestore

final class LoginViewController: BaseViewController {
    
    // Firestore
    private let firestoreManager = FirestoreManager.shared
    
    // Metamask
//    private let appMetadata = AppMetadata(name: "MyNFTTracker", url: "https://my-nft-tracker.com")
    private let metamaskManager = MetamaskManager.shared
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateLayout()
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let `self` = self else { return }
            self.view.layoutIfNeeded()
            self.loginButton.alpha = 1.0
            self.signupButton.alpha = 1.0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
    }
    
}

extension LoginViewController {
    
    private func bind() {

        let metamask = metamaskManager.metaMaskSDK
        
        self.loginButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
            
                self.addChildViewController(self.loadingVC)
                
                Task {
                    let result = await metamask.connect()
                    switch result {
                    case .success(let address):
//                        self.saveAddressAndChainId(address: address, chainId: metamask.chainId)
                        self.vm.address = address
                        self.vm.walletConnected = true

                        #if DEBUG
                        if metamask.connected {
                            print("Metamask connected")
                        } else {
                            print("Metamask NOT connected")
                        }
                        #endif
                    case .failure(let error):
                        self.showWalletConnectionFailedAlert(title: LoginConstants.failedToConnectWallet,
                                                             message: LoginConstants.tryAgain)
                        AppLogger.logger.error("Connection error: \(String(describing: error))")
                    }
                    DispatchQueue.main.async {
                        self.loadingVC.removeViewController()
                    }
                }
                //TODO: LoginVC에서 메타마스크 에러로 결과를 제대로 받아오지 못할 때 핸들링 로직 필요.
                
            }
            .store(in: &bindings)
        
        self.vm.$walletConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let `self` = self else { return }
                
                if connected {
                   
                    Task {
                        guard let wallet = self.vm.address else { return }
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
                      let wallet = self.vm.address
                else { return }
                
                if $0 {
                    Task {
                        DispatchQueue.main.async {
                            let welcomeVM = WelcomeViewViewmodel(address: wallet)
                            let welcomeVC = WelcomeViewController(vm: welcomeVM)
                            
                            self.show(welcomeVC, sender: self)
                        }
                    }
                    
                } else {
                    self.vm.saveAddressAndChainId(address: wallet, chainId: metamask.chainId)
                    DispatchQueue.main.async {
                        print("User \(wallet) already registered. Direct to MainVC")
                        let vc = MainViewController(vm: MainViewViewModel())
                        vc.delegate = self
                        self.show(vc, sender: self)
                    }
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
        
        self.vm.receivedError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if let userNotFound = error as? FirestoreErrorCode {
                        if userNotFound == FirestoreErrorCode(.notFound) {
                            self.showWalletConnectionFailedAlert(title: LoginConstants.userNotFound,
                                                                 message: LoginConstants.tryAgain)
                        }
                    } else {
                        self.showWalletConnectionFailedAlert(title: LoginConstants.retryTitle,
                                                             message: LoginConstants.tryAgain + "\n Error: " + error.localizedDescription)
                    }
                }

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
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.view.frame.height / 2)
        }
        
        self.loginButton.snp.makeConstraints {
//            $0.top.equalTo(self.logo.snp.bottom).offset(40)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
        
        self.signupButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.loginButton.alpha = 0.0
        self.signupButton.alpha = 0.0
    }
    
    private func updateLayout() {
        
        self.logo.snp.remakeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.view.frame.height / 2)
        }
        
        self.loginButton.snp.remakeConstraints {
            $0.top.equalTo(self.logo.snp.bottom).offset(40)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
        
        self.signupButton.snp.remakeConstraints {
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
    
    private func retrieveWalletAddress() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress)
    }
    
    
    private func showWalletConnectionFailedAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LoginConstants.confirm,
                                      style: .cancel))
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.present(alert, animated: true)
        }
    }
}

extension LoginViewController: BaseViewControllerDelegate {
    
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
    
    func userInfoChanged(as user: User) {
        return
    }
    
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

extension LoginViewController: MainViewControllerDelegate {
    func errorDidReceive(_ viewController: UIViewController, error: Error) {
        self.vm.receivedError.send(error)
    }
}
