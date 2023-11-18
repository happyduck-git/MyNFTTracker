//
//  NftCardCell.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit

protocol NftCardCellDelegate: AnyObject {
    func didTapTemplateButton()
}

final class NFTCardCell: UICollectionViewCell {
    
    weak var delegate: NftCardCellDelegate?

    //MARK: - UI Elements

    let cardFrontView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20.0
        imageView.isHidden = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cardBackView: NFTCardBackView = {
        let view = NFTCardBackView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 20.0
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.cardFrontView.setGradientBorder(
                colors: [AppColors.frameGradientPurple,
                         AppColors.frameGradientMint,
                         .white],
                startPoint: CGPoint(x: 0.0, y: 0.0),
                endPoint: CGPoint(x: 1.0, y: 1.0),
                borderWidth: 5.0)
        }
    }
    
    //MARK: - Set UI and Layout
    
    private func setUI() {
        
        self.addSubviews(self.cardFrontView,
                         self.cardBackView)
        
    }
    
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            cardFrontView.topAnchor.constraint(equalTo: self.topAnchor),
            cardFrontView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardFrontView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardFrontView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
           
            cardBackView.topAnchor.constraint(equalTo: self.topAnchor),
            cardBackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardBackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardBackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    
    //MARK: - Configuration
    func configureFront(with image: UIImage, isHidden: Bool) {
        self.cardFrontView.isHidden = isHidden
        self.cardFrontView.image = image
    }
    
    func configureBack(with nft: OwnedNFT, isHidden: Bool) {
        self.cardBackView.isHidden = isHidden
        self.cardBackView.configure(with: nft)
    }
    
    func toggleToHide(
        front: Bool,
        back: Bool
    ) {
        self.cardFrontView.isHidden = front
        self.cardBackView.isHidden = back
    }
    
    func resetCell() {
        self.cardFrontView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cardFrontView.isHidden = false
        self.cardBackView.isHidden = true
    }
}

extension NFTCardCell: NftTraitViewDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}
