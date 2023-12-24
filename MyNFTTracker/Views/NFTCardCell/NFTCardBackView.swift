//
//  NFTCardBackView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/15/23.
//

import UIKit
import SnapKit

enum TokenSymbol: String {
    case eth = "eth"
    case polygon = "polygon"
}

final class NFTCardBackView: UIView {
    
    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.font = UIFont.appFont(name: .appMainFontBold, size: .title)
        return label
    }()
    
    private let tokenIdLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.textColor = .darkGray
        label.font = UIFont.appFont(name: .appMainFontLight, size: .light)
        return label
    }()
    
    private let symbolImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.appFont(name: .appMainFontMedium, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contractStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let contractTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.text = String(localized: "Contract")
        label.font = UIFont.appFont(name: .appMainFontBold, size: .plain)
        return label
    }()
    
    private let contractAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.textAlignment = .right
        label.font = UIFont.appFont(name: .appMainFontLight, size: .plain)
        return label
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

extension NFTCardBackView {
    func configure(with nft: OwnedNFT) {
        
        let nftTitle: String = nft.title.isEmpty ? "No Name Found!" : nft.title
        self.nameLabel.text = nftTitle
        
        self.tokenIdLabel.text = nft.id.tokenId
        self.descLabel.text = nft.description
        self.contractAddressLabel.text = nft.contract.address

    }
}

extension NFTCardBackView {
    private func setUI() {
        self.addSubviews(
            self.nameStack,
            self.symbolImage,
            self.descLabel,
            self.contractStack
        )
        
        self.nameStack.addArrangedSubviews(
            self.nameLabel,
            self.tokenIdLabel
        )
        
        self.contractStack.addArrangedSubviews(
            self.contractTitleLabel,
            self.contractAddressLabel
        )
        
        self.nameStack.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setLayout() {
        self.nameStack.snp.makeConstraints {
            $0.top.leading.equalTo(self).offset(20)
            $0.trailing.equalTo(self.symbolImage.snp.leading).offset(-10)
        }
        
        self.symbolImage.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.trailing.equalTo(self).offset(-20)
            $0.height.width.equalTo(20)
        }
        
        self.descLabel.snp.makeConstraints {
            $0.top.equalTo(self.nameStack.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.nameStack)
        }
        
        self.contractStack.snp.makeConstraints {
            $0.top.equalTo(self.descLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.nameStack)
            $0.bottom.lessThanOrEqualTo(self).offset(-10)
        }
    }
}
