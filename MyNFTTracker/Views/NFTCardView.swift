//
//  NFTCardView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import Combine
import Nuke

 protocol NFTCardViewDelegate: AnyObject {
     func didTapTemplateButton()
 }

 final class NFTCardView: UIView {
     
     var nftSelected: [Bool] = []
     
     // MARK: - UIElements
     
     private let viewModel: NFTCardViewViewModel?
     weak var delegate: NFTCardViewDelegate?
     
     private let stackView: UIStackView = {
         let stackView = UIStackView()
         
         stackView.axis = .horizontal
         stackView.spacing = 1.0
         stackView.accessibilityIdentifier = "nftCardStackView"
         stackView.translatesAutoresizingMaskIntoConstraints = false
         return stackView
     }()
     
     private let numbersOfNft: UILabel = {
         let label = UILabel()
         label.text = "3"
         label.font = .appFont(name: .appMainFontBold, size: .plain)
         label.textColor = AppColors.gradientPink
         return label
     }()
     
     private let numbersOfNftDescription: UILabel = {
         let label = UILabel()
         label.text = String(localized: "개의 NFT")
         label.font = .appFont(name: .appMainFontMedium, size: .plain)
         label.textColor = .darkGray
         return label
     }()
     
     private let nftCollectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
         
         let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
         collectionView.register(NFTCardCell.self, forCellWithReuseIdentifier: NFTCardCell.identifier)
         collectionView.accessibilityIdentifier = "nftCollectionView"
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.translatesAutoresizingMaskIntoConstraints = false
         collectionView.backgroundColor = .white
         collectionView.alpha = 0.0
         return collectionView
         
     }()
     
     // MARK: - Init
     init(vm: NFTCardViewViewModel) {
         self.viewModel = vm
         super.init(frame: .zero)
         
         setUI()
         layout()
         setDelegate()
         
         bind()
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     // MARK: - Set UI and Layout
     private func setUI() {
         self.addSubview(stackView)
         self.stackView.addArrangedSubview(numbersOfNft)
         self.stackView.addArrangedSubview(numbersOfNftDescription)
         
         self.addSubview(nftCollectionView)
     }
     
     private func setDelegate() {
         
         self.nftCollectionView.delegate = self
         self.nftCollectionView.dataSource = self
     }
     
     private func layout() {
         
         NSLayoutConstraint.activate([
             
             stackView.topAnchor.constraint(equalTo: self.topAnchor),
             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
             
             nftCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
             nftCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
             nftCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             nftCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
             
         ])
         
         stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
     }
     
 }

 //MARK: - CollectionView Delegate & DataSource

 extension NFTCardView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
         let numberOfNfts = viewModel?.nfts.count ?? 0
         self.numbersOfNft.text = String(numberOfNfts)
         
         nftSelected = Array(repeating: false, count: numberOfNfts)
         
         return numberOfNfts

     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
         
         guard let nft = viewModel?.nfts[indexPath.row] else {
             fatalError("No nft value found")
         }
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCardCell.identifier, for: indexPath) as? NFTCardCell else {
             fatalError("Unsupported cell")
         }
         
         if nftSelected[indexPath.row] == false {
             cell.resetCell()
         } else {
             cell.selectViewToHide(cardBackView: false, nftImageView: true)
         }
         
         cell.delegate = self
         
         cell.backgroundColor = .white
         
         makeCellRadius(of: cell)
         makeCellShadow(of: cell)
         
         /*
         let url = URL(string: nft.imageUrl)!
         
         
         ImagePipeline.shared.loadImage(with: url) { result in
             switch result {
             case .success(let imageResponse):
                 cell.configureImage(image: imageResponse.image)
             case .failure(let failure):
                 print("Nuke load image failed: \(failure)")
             }
         }
          */
         DispatchQueue.main.async {
             
             UIView.animate(withDuration: 0.4) {
                 self.nftCollectionView.alpha = 1.0
             }
             
             
            /* //TODO: Need to change configure arguments according to NFTModel properties.
             cell.configure(
                 name: nft.name,
                 rank: nft.traits.rank,
                 score: nft.score,
                 updatedAt: nft.updateAt
             )
             */
         }
         
         
         return cell
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let viewFrameHeight = self.nftCollectionView.frame.size.height
         let viewFrameWidth = self.nftCollectionView.frame.size.width
         return CGSize(width: viewFrameWidth / 1.3, height: viewFrameHeight - 30)
     }
     
     private func makeCellRadius(of cell: UICollectionViewCell) {
         cell.layer.cornerRadius = 20.0
         cell.layer.borderWidth = 1.0
         cell.layer.borderColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1).cgColor
     }
     
     private func makeCellShadow(of cell: UICollectionViewCell) {
         cell.layer.masksToBounds = false
         cell.layer.shadowRadius = 8.0
         cell.layer.shadowOpacity = 1
         cell.layer.shadowColor = UIColor(red: 0.696, green: 0.696, blue: 0.696, alpha: 0.5).cgColor
         cell.layer.shadowOffset = CGSize(width: 4, height: 4)
         cell.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 4, y: 10, width: cell.frame.width, height: cell.frame.height - 10), cornerRadius: 20).cgPath
         cell.layer.shadowOffset = CGSize(width: 4, height: 4)
     }
     
     
  
 }

 //MARK: - ViewModel bind

 extension NFTCardView {
     
     private func bind() {
         /*
         viewModel.bellyGomNfts.bind { [weak self] _ in
             DispatchQueue.main.async {
                 self?.nftCollectionView.reloadData()
             }
         }
          */
     }
     
     private func fetchBellyGomNft() {
         /*
         let tempAddress: String = K.Wallet.temporaryAddress
         self.viewModel.getNfts(of: tempAddress) { nfts in
             self.viewModel.bellyGomNfts.value = nfts
         }
          */
     }
 }

 //MARK: - NftCardCellDelegate

 extension NFTCardView: NftCardCellDelegate {
     
     func didTapTemplateButton() {
         delegate?.didTapTemplateButton()
     }
     
 }

