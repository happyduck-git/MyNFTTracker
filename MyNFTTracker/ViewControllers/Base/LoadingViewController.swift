//
//  LoadingViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import SnapKit

final class LoadingViewController: UIViewController {

    private let spinnerBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .white
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGray
        self.view.alpha = 0.2
        
        self.setUI()
        self.setLayout()
        
        self.spinner.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.spinner.stopAnimating()
        
        self.navigationItem.hidesBackButton = true
    }

}

extension LoadingViewController {
    private func setUI() {
        self.view.addSubview(self.spinnerBackground)
        self.spinnerBackground.addSubview(self.spinner)
    }
    
    private func setLayout() {
        self.spinnerBackground.snp.makeConstraints {
            $0.center.equalTo(self.view)
            $0.width.height.equalTo(80)
        }
        
        self.spinner.snp.makeConstraints {
            $0.center.equalTo(self.spinnerBackground)
        }
    }
}
