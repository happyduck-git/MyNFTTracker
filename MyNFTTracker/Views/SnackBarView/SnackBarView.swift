//
//  SnackBarView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/29/23.
//

import UIKit
import SnapKit

final class SnackBarView: UIView {

    private let vm: SnackbarViewViewModel
    
    private var handler: Handler?
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    init(vm: SnackbarViewViewModel) {
        self.vm = vm
        super.init(frame: .zero)
        
        self.setUI()
        self.setLayout()
        self.configure()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 11.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SnackBarView {
    private func setUI() {
        self.backgroundColor = .systemGreen
        self.addSubview(self.textLabel)
    }
    
    private func setLayout() {
        self.textLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.bottom.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension SnackBarView {
    func configure() {
        self.textLabel.text = self.vm.text
        
        switch self.vm.type {
        case .action(let handler):
            self.handler = handler
        }
    }
}
