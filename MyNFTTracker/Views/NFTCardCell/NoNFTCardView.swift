//
//  NoNFTCardView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/8/23.
//

import UIKit
import SnapKit

final class NoNFTCardView: UIView {

    //MARK: - UI Elements
    private let noNftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .noNftEmoji)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let noNftLabel: UILabel = {
        let label = UILabel()
        label.text = MainViewConstants.noNft
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .appFont(name: .appMainFontBold, size: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NoNFTCardView {
    private func setUI() {
        self.addSubviews(self.noNftImage,
                         self.noNftLabel)
    }
    
    private func setLayout() {
        self.noNftImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(self.noNftLabel)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }
        self.noNftLabel.snp.makeConstraints {
            $0.top.equalTo(self.noNftImage.snp.bottom).offset(-10)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }
}

extension NoNFTCardView {
    func configure(textColor: UIColor?, imageColor: UIColor?) {
        self.noNftLabel.textColor = textColor?.withAlphaComponent(0.8)
        self.noNftImage.image?.withTintColor(imageColor!, renderingMode: .alwaysOriginal)
    }
}
