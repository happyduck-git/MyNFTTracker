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
    
    private let selectChainButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(LoginConstants.selectChain, for: .normal)
        btn.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.3)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10.0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10.0
        textField.placeholder = LoginConstants.address
        textField.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.3)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let addressValidationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .appFont(name: .appMainFontLight, size: .light)
        label.textColor = .systemRed
        label.text = LoginConstants.wrongAddress
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10.0
        btn.backgroundColor = .systemOrange
        btn.setTitle(LoginConstants.login, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.numberOfLines = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let divider: OrDivider = {
        let view = OrDivider()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let metamaskLoginButton: UIButton = {
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
        self.dismissKeyboard()
        
        self.updateTheme()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bind()
        self.setNotification()
        
        self.setButtonMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateLayout()
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let `self` = self else { return }
            self.view.layoutIfNeeded()
            self.addressTextField.alpha = 1.0
            self.loginButton.alpha = 1.0
            self.divider.alpha = 1.0
            self.metamaskLoginButton.alpha = 1.0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.metamaskLoginButton.layer.cornerRadius = self.metamaskLoginButton.frame.height / 2
    }
    
}

extension LoginViewController {
    
    private func bind() {
        
        self.vm.transform()
        
        func bindViewToViewModel() {
            self.loginButton.tapPublisher
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let address = self.addressTextField.text else { return }
                    self.addChildViewController(self.loadingVC)
                    self.vm.walletSigninTapped.send(address)
                }
                .store(in: &bindings)
            
            self.metamaskLoginButton.tapPublisher
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.addChildViewController(self.loadingVC)
                    self.vm.metamaskSigninTapped.send(())
                }
                .store(in: &bindings)

            self.addressTextField.textPublisher
                .sink { [weak self] text in
                    guard let `self` = self else { return }
                    self.vm.textFieldText = text
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {

            self.vm.isFirstVisit
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    let wallet = self.vm.address
            
                    if $0 {

                        let welcomeVM = WelcomeViewViewmodel(address: wallet, chainId: self.vm.selectedChain)
                        let welcomeVC = WelcomeViewController(vm: welcomeVM)
                        
                        self.show(welcomeVC, sender: self)
                        
                    } else {
                        self.vm.saveAddressAndChainId(address: wallet, chainId: self.vm.selectedChain)
                        
                        #if DEBUG
                        print("User \(wallet) already registered. Direct to MainVC")
                        #endif

                        let vc = MainViewController(vm: MainViewViewModel())
                        vc.delegate = self
                        self.show(vc, sender: self)
                        
                    }
                    
                    self.addressTextField.text = nil
                    self.vm.selectedChain = String()
                    self.vm.address = String()
                    self.addressValidationLabel.isHidden = true
                    self.loadingVC.removeViewController()
                    
                }
                .store(in: &bindings)
            
            self.vm.errorTracker
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        
                        if let userNotFound = error as? FirestoreErrorCode {
                            if userNotFound == FirestoreErrorCode(.notFound) {
                                self.showWalletConnectionFailedAlert(title: LoginConstants.userNotFound,
                                                                     message: LoginConstants.tryAgain)
                            }
                            
                        } else if let wrongFormat = error as? LoginViewViewModel.LoginError {
                            switch wrongFormat {
                            case .wrongAddressFormat:
                                #if DEBUG
                                print("Wrong format id")
                                #endif
                                
                                self.addressValidationLabel.isHidden = false
                                self.loadingVC.removeViewController()
                            case .walletNotConnected:
                                #if DEBUG
                                print("Not connected id")
                                #endif
                                
                                self.loadingVC.removeViewController()
                            }
                        
                        } else {
                            self.showWalletConnectionFailedAlert(
                                title: LoginConstants.retryTitle,
                                message: LoginConstants.tryAgain + "\n Error: " + error.localizedDescription)
                        }
                    }

                }
                .store(in: &bindings)
            
            self.vm.$selectedChain
                .receive(on: DispatchQueue.main)
                .dropFirst()
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    let chainId = $0.isEmpty ? LoginConstants.selectChain : Chain(rawValue: $0)?.network
                    
                    self.selectChainButton.setTitle(chainId, for: .normal)
                }
                .store(in: &bindings)
            
            self.vm.activateLoginButton
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let theme = self.vm.theme else { return }
                    self.loginButton.isUserInteractionEnabled = $0 ? true : false
                    
                    var activatedColor: UIColor?
                    var deactivatedColor: UIColor?
                    switch theme {
                    case .black:
                        activatedColor = AppColors.DarkMode.buttonActive
                        deactivatedColor = AppColors.DarkMode.buttonInactive
                    case .white:
                        activatedColor = AppColors.LightMode.buttonActive
                        deactivatedColor = AppColors.LightMode.buttonInactive
                    }
                    
                    self.loginButton.backgroundColor = $0 ? activatedColor : deactivatedColor
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
        
    }
    
}

extension LoginViewController {
    
    private func setUI() {
        self.view.addSubviews(self.logo,
                              self.selectChainButton,
                              self.addressTextField,
                              self.addressValidationLabel,
                              self.loginButton,
                              self.divider,
                              self.metamaskLoginButton)
    }
    
    private func setLayout() {
        self.logo.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.selectChainButton.snp.makeConstraints {
            $0.top.equalTo(self.logo.snp.bottom).offset(100)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(40)
        }
        
        self.addressTextField.snp.makeConstraints {
            $0.top.equalTo(self.selectChainButton.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(40)
        }
        
        self.loginButton.snp.makeConstraints {
            $0.top.equalTo(self.selectChainButton.snp.top)
            $0.leading.equalTo(self.addressTextField.snp.trailing).offset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.loginButton.snp.width)
        }
        
        self.divider.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(40)
        }
        
        self.metamaskLoginButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
        
        self.addressTextField.alpha = 0.0
        self.loginButton.alpha = 0.0
        self.divider.alpha = 0.0
        self.metamaskLoginButton.alpha = 0.0
    }
    
    private func updateLayout() {
        
        self.logo.snp.remakeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.selectChainButton.snp.remakeConstraints {
            $0.top.equalTo(self.logo.snp.bottom).offset(100)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(40)
        }
        
        self.addressTextField.snp.remakeConstraints {
            $0.top.equalTo(self.selectChainButton.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.selectChainButton.snp.trailing)
            $0.height.equalTo(40)
        }
        
        self.addressValidationLabel.snp.makeConstraints {
            $0.top.equalTo(self.addressTextField.snp.bottom).offset(5)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.loginButton.snp.remakeConstraints {
            $0.top.equalTo(self.selectChainButton.snp.top)
            $0.bottom.equalTo(self.addressTextField.snp.bottom)
            $0.leading.equalTo(self.selectChainButton.snp.trailing).offset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(self.loginButton.snp.width)
        }
        
        self.divider.snp.remakeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(30)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(40)
        }
        
        self.metamaskLoginButton.snp.remakeConstraints {
            $0.top.equalTo(self.divider.snp.bottom).offset(30)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
            $0.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-20)
        }

    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }

}

extension LoginViewController {
    private func setButtonMenu() {
        let chains: [Chain] = Chain.allCases
        var menuItems: [UIAction] = []
        
        for chain in chains {
            menuItems.append(UIAction(title: chain.network, handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.vm.selectedChain = chain.rawValue
            }))
        }
        
        let menu = UIMenu(children: menuItems)
        menu.preferredElementSize = .large
        self.selectChainButton.menu = menu
        self.selectChainButton.showsMenuAsPrimaryAction = true

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
        self.vm.theme = theme
        
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
        
        self.selectChainButton.setTitleColor(textColor, for: .normal)
        self.loginButton.backgroundColor = buttonColor
        self.loginButton.setTitleColor(textColor, for: .normal)
        
        self.divider.configureColor(textColor)
        
        self.metamaskLoginButton.backgroundColor = buttonColor
        self.metamaskLoginButton.layer.borderColor = borderColor?.cgColor
        self.metamaskLoginButton.setTitleColor(textColor, for: .normal)
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
        self.vm.errorTracker.send(error)
    }
}

extension LoginViewController {
    func setNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotificationConstants.metamaskConnection),
                                               object: nil,
                                               queue: nil) { [weak self] noti in
            guard let `self` = self else { return }
            self.vm.walletConnected = false
            let metamask = metamaskManager.metaMaskSDK
            metamask.terminateConnection()
        }
    }
}
