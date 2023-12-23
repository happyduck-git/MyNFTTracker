//
//  ChainConnectionStatusView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/22/23.
//

import UIKit
import Nuke

enum ConnectionStatus {
    case connected
    case disconnected
}

final class ChainConnectionStatusView: UIView {
    
    private let statusIcon: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let connectionLabel: UILabel = {
        let label = UILabel()
        label.text = MainViewConstants.connectedChain
        label.font = .appFont(name: .appMainFontLight, size: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chainNameLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(name: .appMainFontLight, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.statusIcon.layer.cornerRadius = self.statusIcon.frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChainConnectionStatusView {

    func configure(with chainName: String,
                   status: ConnectionStatus) {
        var color: UIColor?
        
        switch status {
        case .connected:
            color = .systemGreen
        case .disconnected:
            color = .systemRed
        }
        self.statusIcon.backgroundColor = color
        self.chainNameLabel.text = chainName
    }
    
    func setTextColor(with color: UIColor?) {
        self.connectionLabel.textColor = color
        self.chainNameLabel.textColor = color
    }
}

extension ChainConnectionStatusView {
    private func setUI() {
        self.addSubviews(self.statusIcon,
                         self.connectionLabel,
                         self.chainNameLabel)
    }
    
    private func setLayout() {
        self.statusIcon.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(10)
            $0.centerY.equalTo(self.connectionLabel.snp.centerY)
        }
        self.connectionLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(self.statusIcon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
        }
        self.chainNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.connectionLabel.snp.bottom)
            $0.leading.equalTo(self.connectionLabel.snp.leading)
            $0.trailing.bottom.equalToSuperview()
        }
    }
}

