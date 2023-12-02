//
//  AvatarCollectionViewCell.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import UIKit
import SnapKit

final class AvatarCollectionViewCell: UICollectionViewCell {
    private let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let checkerImage: UIImageView = {
        let image = UIImageView()
        image.isHidden = true
        image.image = UIImage(
            systemName: "checkmark.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGreen.withAlphaComponent(0.8)
            )
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AvatarCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.image,
                                    self.checkerImage)
    }
    
    private func setLayout() {
        self.image.snp.makeConstraints {
            $0.top.leading.equalTo(self.contentView).offset(10)
            $0.trailing.bottom.equalTo(self.contentView).offset(-10)
        }
        
        self.checkerImage.snp.makeConstraints {
            $0.trailing.bottom.equalTo(self.contentView).offset(-10)
            $0.height.width.equalTo(30)
        }
    }
}

extension AvatarCollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.image.image = nil
        self.checkerImage.isHidden = true
    }
    
    func configure(image: UIImage?, checkHidden status: Bool) {
        self.image.image = image
        self.checkerImage.isHidden = !status
    }
    
    func showCheckmark(_ status: Bool) {
        self.checkerImage.isHidden = !status
    }
}
