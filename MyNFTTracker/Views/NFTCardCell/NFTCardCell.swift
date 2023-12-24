//
//  NftCardCell.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import Gifu
import Nuke

protocol NftCardCellDelegate: AnyObject {
    func didTapTemplateButton()
}

final class NFTCardCell: UICollectionViewCell {
    
    enum CellType {
        case gif
        case `static`
    }
    
    var cellType: CellType?
    
    weak var delegate: NftCardCellDelegate?

    //MARK: - UI Elements
    let cardFrontView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20.0
        imageView.isHidden = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cardAnimatableFrontView: GIFImageView = {
        let imageView = GIFImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20.0
        imageView.isHidden = true
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
            
            self.setGradientCellBorder(to: self.cardFrontView)
            self.setGradientCellBorder(to: self.cardAnimatableFrontView)
        }
    }
    
    //MARK: - Set UI and Layout
    
    private func setUI() {
        
        self.addSubviews(self.cardFrontView,
                         self.cardAnimatableFrontView,
                         self.cardBackView)
        
    }
    
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            cardFrontView.topAnchor.constraint(equalTo: self.topAnchor),
            cardFrontView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardFrontView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardFrontView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cardAnimatableFrontView.topAnchor.constraint(equalTo: self.topAnchor),
            cardAnimatableFrontView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardAnimatableFrontView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardAnimatableFrontView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
           
            cardBackView.topAnchor.constraint(equalTo: self.topAnchor),
            cardBackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardBackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardBackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    
    //MARK: - Configuration
    func configureFront(with url: URL?, isHidden: Bool) {
        if isHidden {
            self.cardFrontView.isHidden = isHidden
            self.cardAnimatableFrontView.isHidden = isHidden
        } else {
            
            guard let url = url else {
                self.setDefaultImage()
                return
            }
            
            if url.absoluteString.hasSuffix(".gif") {
                self.configureForGif(with: url)
            } else {
                self.configureForStaticImage(with: url)
            }
        }
    }
    
    func configureBack(with nft: OwnedNFT, isHidden: Bool) {
        self.cardBackView.isHidden = isHidden
        self.cardBackView.configure(with: nft)
    }
    
    func toggleToHide(
        front: Bool,
        back: Bool
    ) {
        
        switch self.cellType {
        case .gif:
            if front {
                self.cardAnimatableFrontView.isHidden = true
            } else {
                self.cardAnimatableFrontView.isHidden = false
            }
            self.cardFrontView.isHidden = true
        case .static:
            if front {
                self.cardFrontView.isHidden = true
            } else {
                self.cardFrontView.isHidden = false
            }
            self.cardAnimatableFrontView.isHidden = true
        default:
            return
        }
        
        self.cardBackView.isHidden = back
    }
    
    func resetCell() {
        self.cardFrontView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cardFrontView.isHidden = false
        self.cardAnimatableFrontView.isHidden = true
        self.cardBackView.isHidden = true
        self.cardAnimatableFrontView.prepareForReuse()
    }
    
    private func setGradientCellBorder(to cellView: UIView) {
        cellView.setGradientBorder(
            colors: [AppColors.frameGradientPurple,
                     AppColors.frameGradientMint,
                     .white],
            startPoint: CGPoint(x: 0.0, y: 0.0),
            endPoint: CGPoint(x: 1.0, y: 1.0),
            borderWidth: 5.0)
    }
    
}

extension NFTCardCell {
    
    /// Set visibility of front image.
    /// Decide which view to show (Animatable or Static image)
    private func setFrontImageVisibility(staticHidden: Bool, animatableHidden: Bool) {
        cardFrontView.isHidden = staticHidden
        cardAnimatableFrontView.isHidden = animatableHidden
    }
    
    private func setDefaultImage() {
        self.cellType = .static
        self.setFrontImageVisibility(staticHidden: false, animatableHidden: true)
        self.cardFrontView.image = UIImage(resource: .noNft)
    }
    
    /// Configure with GIF type image
    /// - Parameter url: URL
    private func configureForGif(with url: URL) {
        self.cellType = .gif
        self.setFrontImageVisibility(staticHidden: true, animatableHidden: false)
        self.cardAnimatableFrontView.animate(withGIFURL: url)
    }
    
    /// Configure with static image
    /// - Parameter url: URL
    private func configureForStaticImage(with url: URL) {
        self.cellType = .static
        self.setFrontImageVisibility(staticHidden: false, animatableHidden: true)
        self.loadImage(from: url)
    }
    
    /// Load static image from URL
    private func loadImage(from url: URL) {
        Task {
            do {
                let image = try await ImagePipeline.shared.image(for: url)
                
                DispatchQueue.main.async {
                    self.cardFrontView.image = image
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.cardFrontView.image = UIImage(resource: .noNft)
                }
                print("Error fetching image -- \(error.localizedDescription)")
            }
        }
    }
}

extension NFTCardCell: NftTraitViewDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}
