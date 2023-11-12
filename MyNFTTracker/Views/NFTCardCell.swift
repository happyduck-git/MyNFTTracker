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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cardBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.clipsToBounds = true
        view.layer.cornerRadius = 20.0
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var traitButtonImage: UIImage? {
        if !cardFrontView.isHidden {
            return UIImage(named: "info")
        } else {
            return UIImage(named: "house")
        }
    }
    
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
            self.cardFrontView.setGradientBorder()
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
    public func configure(backgroundDesc: String,
                          bodyDesc: String,
                          clothesDesc: String,
                          headDesc: String,
                          accDesc: String,
                          specialDesc: String,
                          
                          name: String,
                          rank: Int,
                          score: Int,
                          updatedAt: Int64) {

    }
    
    func configureImage(image: UIImage) {
        self.cardFrontView.image = image
    }
    
    func selectViewToHide(cardBackView hideCardBackView: Bool, nftImageView hideNftImageView: Bool) {
        self.cardFrontView.isHidden = hideNftImageView
    }
    
    func resetCell() {
        self.cardFrontView.image = nil
        self.cardFrontView.isHidden = false
    }
    
}

extension NFTCardCell: NftTraitViewDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}
