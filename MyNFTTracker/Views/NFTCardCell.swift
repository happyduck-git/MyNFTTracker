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
        imageView.image = UIImage(named: "bellygom_test")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20.0
        imageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let traitView: NftTraitView = {
        let view = NftTraitView()
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
        self.backgroundColor = .white
        
        setUI()
        setLayout()

        traitView.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Set UI and Layout
    
    private func setUI() {
        
        self.addSubviews(self.cardFrontView,
                         self.traitView)
        
    }
    
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            cardFrontView.topAnchor.constraint(equalTo: self.topAnchor),
            cardFrontView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardFrontView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardFrontView.heightAnchor.constraint(equalToConstant: self.frame.size.width),
            
            traitView.topAnchor.constraint(equalTo: cardFrontView.bottomAnchor, constant: 10),
            traitView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            traitView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
            
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
        
        self.traitView.configure(name: name,
                                 rank: rank,
                                 score: score,
                                 updatedAt: updatedAt)
    }
    
    func configureImage(image: UIImage) {
        self.cardFrontView.image = image
    }
    
    func selectViewToHide(cardBackView hideCardBackView: Bool, nftImageView hideNftImageView: Bool) {
        self.cardFrontView.isHidden = hideNftImageView
        self.traitView.changeCardButtonImage(with: traitButtonImage)
    }
    
    func resetCell() {
      
        self.traitView.configure(name: nil, rank: nil, score: nil, updatedAt: nil)
        self.traitView.cardButton.imageView?.image = UIImage(named: "front_deco_button")
        self.cardFrontView.image = nil
        
        self.cardFrontView.isHidden = false
        
    }
    
}

extension NFTCardCell: NftTraitViewDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}
