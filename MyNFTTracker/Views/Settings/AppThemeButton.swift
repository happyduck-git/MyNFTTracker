//
//  AppThemeButton.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/5/23.
//

import UIKit
import Combine
import SnapKit

final class AppThemeButton: UIButton {
    
    private let containerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let themeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.font = .appFont(name: .appMainFontMedium, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let radioButtonIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppThemeButton {
    func configure(image: UIImage?, title: String) {
        self.themeImageView.image = image
        self.themeLabel.text = title
    }
    
    func toggleButton(_ selected: Bool) {
        self.radioButtonIcon.image = selected ? UIImage(systemName: "circle.inset.filled") : UIImage(systemName: "circle")
        self.layer.borderColor = selected ? AppColors.selectedBorder.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = selected ? 2 : 0
    }
    
    func configureTextColor(with color: UIColor?) {
        self.themeLabel.textColor = color
    }
}

extension AppThemeButton {
    private func setUI() {
        self.addSubview(self.containerView)
        self.containerView.addSubviews(self.themeImageView,
                                       self.themeLabel,
                                       self.radioButtonIcon)
    }
    
    private func setLayout() {
        self.containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.themeImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.themeLabel.snp.top).offset(-10)
        }
        
        self.themeLabel.snp.makeConstraints {
            $0.top.equalTo(self.themeImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.themeImageView)
            $0.height.equalTo(30)
            $0.bottom.equalTo(self.radioButtonIcon.snp.top).offset(-10)
        }
        
        self.radioButtonIcon.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.themeLabel.snp.bottom).offset(10)
            $0.width.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

}
