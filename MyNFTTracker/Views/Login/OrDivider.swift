//
//  OrDivider.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 1/3/24.
//

import UIKit
import SnapKit

final class OrDivider: UIView {
    
    private let divider1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLable: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.or
        label.font = .appFont(name: .appMainFontLight, size: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let divider2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OrDivider {
    func configureColor(_ color: UIColor?) {
        self.divider1.backgroundColor = color
        self.divider2.backgroundColor = color
        self.orLable.textColor = color
    }
}

//MARK: - Set UI & Layout
extension OrDivider {
    private func setUI() {
        self.addSubviews(self.divider1,
                         self.orLable,
                         self.divider2)
    }
    
    private func setLayout() {
        self.divider1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.orLable.snp.leading).offset(-10)
            make.centerY.equalTo(self.orLable)
            make.height.equalTo(1)
        }
        
        self.orLable.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.divider2.snp.makeConstraints { make in
            make.leading.equalTo(self.orLable.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.orLable)
            make.height.equalTo(1)
        }
    }
}
