//
//  LoadingViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import SnapKit
import Lottie

final class LoadingViewController: UIViewController {

    private let spinnerBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black.withAlphaComponent(0.5)

        self.setUI()
        self.setLayout()
        Task {
            await self.loadLottie()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.loadingView.isAnimationPlaying {
            self.loadingView.play()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.loadingView.stop()
        
        self.navigationItem.hidesBackButton = true
    }

}

extension LoadingViewController {
    private func setUI() {
        self.view.addSubview(self.spinnerBackground)
        self.spinnerBackground.addSubview(self.loadingView)
    }
    
    private func setLayout() {
        self.spinnerBackground.snp.makeConstraints {
            $0.center.equalTo(self.view)
            $0.width.height.equalTo(80)
        }
        self.loadingView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
    }
}
extension LoadingViewController {
    private func loadLottie() async {
        do {
            guard let url = Bundle.main.url(forResource: "loading", withExtension: "lottie") else {
                print("Error url")
                return
            }
            
            let dotLottie = try await DotLottieFile.loadedFrom(url: url)
            loadingView.loadAnimation(from: dotLottie)
            loadingView.loopMode = .loop
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.loadingView.play()
            }
        }
        catch {
            AppLogger.logger.error("Error playing DotLottie -- \(error)")
        }
    }
}
