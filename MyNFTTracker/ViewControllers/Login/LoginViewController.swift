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
    
    // Metamask
    private let ethereum = MetaMaskSDK.shared.ethereum
    private let dapp = Dapp(name: "MyNFTTracker", url: "https://my-nft-tracker.com")
    
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
        btn.backgroundColor = AppColors.buttonBeige
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
        
        let gradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                              colors: [AppColors.gradientPink,
                                       AppColors.gradientGreen])
        view.backgroundColor = UIColor(patternImage: gradientImage)
        
        self.setUI()
        self.setLayout()
        
        self.bind()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
    }
    
}

extension LoginViewController {
    
    private func bind() {
        
        self.loginButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
            
                self.addChildViewController(self.loadingVC)
                
                ethereum.connect(self.dapp)?
                    .sink(receiveCompletion: { [weak self] completion in
                        guard let `self` = self else { return }
                        
                        switch completion {
                        case let .failure(error):
                            self.loadingVC.removeViewController()
                            self.showWalletConnectiontFailedAlert()
                            AppLogger.logger.error("Connection error: \(String(describing: error))")
                            
                        default: break
                        }
                    }, receiveValue: { result in
                        self.loadingVC.removeViewController()
                        AppLogger.logger.info("Connection result: \(String(describing: result))")
                        self.saveWalletAddress(address: result as? String)
                        self.vm.walletConnected = true
                    }).store(in: &bindings)
                
            }
            .store(in: &bindings)
        
        self.vm.$walletConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let `self` = self else { return }
                
                if connected {
                    
                    let vc = MainViewController(vm: MainViewViewModel())
                    
                    self.show(vc, sender: self)
                }
                
            }.store(in: &bindings)
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

// MARK: - Private
extension LoginViewController {
    
    private func saveWalletAddress(address: String?) {
        UserDefaults.standard.set(address, forKey: UserDefaultsConstants.walletAddress)
    }
    
    private func showWalletConnectiontFailedAlert() {
        self.showAlert(alertTitle: "지갑 연결 실패",
                       alertMessage: "다시 한번 시도해주세요.",
                       alertStyle: .alert,
                       actionTitle1: "확인",
                       actionStyle1: .cancel)
    }
}
