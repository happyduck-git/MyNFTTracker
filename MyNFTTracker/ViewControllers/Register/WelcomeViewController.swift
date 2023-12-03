//
//  WelcomeViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import UIKit
import Lottie
import SnapKit

final class WelcomeViewController: BaseViewController {
    
    private let vm: WelcomeViewViewmodel
    
    private let confettiView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.loopMode = .loop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeTitle: UILabel = {
        let label = UILabel()
        label.text = WelcomeConstants.welcome
        label.textAlignment = .center
        label.font = .appFont(name: .appMainFontBold, size: .big)
        label.textColor = AppColors.DarkMode.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setNavigationBarItem()
        Task {
            await self.loadLottie()
        }
    }
    
    //MARK: - Init
    init(vm: WelcomeViewViewmodel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WelcomeViewController {
    private func setUI() {
        self.view.addSubviews(self.welcomeTitle,
                              self.confettiView)
    }
    
    private func setLayout() {
        self.welcomeTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        self.confettiView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func setNavigationBarItem() {
        let rightBarButtonItem = UIBarButtonItem(
            title: RegisterViewConstants.next,
            style: .plain,
            target: self,
            action: #selector(nextDidTap(_:)))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func nextDidTap(_ sender: UIBarButtonItem) {
        let vm = RegisterViewViewModel(walletAddres: self.vm.address)
        let vc = RegisterViewController(vm: vm)
        self.show(vc, sender: self)
    }
}

extension WelcomeViewController {
    private func loadLottie() async {
        do {
            guard let url = Bundle.main.url(forResource: "confetti", withExtension: "lottie") else {
                return
            }
            
            let dotLottie = try await DotLottieFile.loadedFrom(url: url)
            confettiView.loadAnimation(from: dotLottie)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.confettiView.play()
            }
        }
        catch {
            AppLogger.logger.error("Error playing DotLottie -- \(error)")
        }
    }
}
