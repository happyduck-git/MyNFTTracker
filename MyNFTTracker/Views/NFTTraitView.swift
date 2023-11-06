//
//  NFTTraitView.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit

protocol NftTraitViewDelegate: AnyObject {
    func didTapTemplateButton()
}

final class NftTraitView: UIView {
    
    weak var delegate: NftTraitViewDelegate?
        
    //MARK: - UI elements
    
    // Nft name and level
    private let nameAndLevelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "level_belly")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nftName: UILabel = {
        let label = UILabel()
        label.text = "Bellygom #1920"
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var cardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "front_deco_button")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(presentTemplateVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //nft traits
    private let rankingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let rankingLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "랭킹")
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let rankingNumLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = AppColors.gradientPink
        return label
    }()
    
    private let scoreStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "점수")
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let scoreNumLabel: UILabel = {
        let label = UILabel()
        label.text = "2594"
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = AppColors.gradientPink
        return label
    }()
    
    private let withMeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let withMeLabel: UILabel = {
        let label = UILabel()
        label.text = "With me"
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let withMeNumLabel: UILabel = {
        let label = UILabel()
        label.text = "D+ 291"
        label.font = .appFont(name: .appMainFontLight, size: 14)
        label.textColor = AppColors.gradientPink
        return label
    }()
    
    private let verticalLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let verticalLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
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
    
    /// Change cardButtonImage
    /// - Parameter image: Desired card button image
    public func changeCardButtonImage(with image: UIImage?) {
        self.cardButton.imageView?.image = image
    }
    
    
    //MARK: - Set up UI and Layout
    private func setUI() {
        
        self.addSubview(nameAndLevelStack)
        self.addSubview(cardButton)
        nameAndLevelStack.addArrangedSubview(levelImageView)
        nameAndLevelStack.addArrangedSubview(nftName)

        self.addSubview(rankingStackView)
        rankingStackView.addArrangedSubview(rankingLabel)
        rankingStackView.addArrangedSubview(rankingNumLabel)

        self.addSubview(verticalLine1)

        self.addSubview(scoreStackView)
        scoreStackView.addArrangedSubview(scoreLabel)
        scoreStackView.addArrangedSubview(scoreNumLabel)

        self.addSubview(verticalLine2)

        self.addSubview(withMeStackView)
        withMeStackView.addArrangedSubview(withMeLabel)
        withMeStackView.addArrangedSubview(withMeNumLabel)
        
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            
            nameAndLevelStack.topAnchor.constraint(equalTo: self.topAnchor),
            nameAndLevelStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            cardButton.topAnchor.constraint(equalTo: nameAndLevelStack.topAnchor),
            cardButton.leadingAnchor.constraint(equalTo: nameAndLevelStack.trailingAnchor, constant: 44),
            cardButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardButton.bottomAnchor.constraint(equalTo: nameAndLevelStack.bottomAnchor),

            rankingStackView.topAnchor.constraint(equalTo: nameAndLevelStack.bottomAnchor, constant: 15),
            rankingStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            rankingStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            verticalLine1.topAnchor.constraint(equalTo: nameAndLevelStack.bottomAnchor, constant: 23),
            verticalLine1.widthAnchor.constraint(equalToConstant: 1),
            verticalLine1.leadingAnchor.constraint(equalTo: rankingStackView.trailingAnchor, constant: 11.5),
            verticalLine1.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),

            scoreStackView.topAnchor.constraint(equalTo: rankingStackView.topAnchor),
            scoreStackView.leadingAnchor.constraint(equalTo: verticalLine1.trailingAnchor, constant: 11.5),
            scoreStackView.bottomAnchor.constraint(equalTo: rankingStackView.bottomAnchor),

            verticalLine2.topAnchor.constraint(equalTo: verticalLine1.topAnchor),
            verticalLine2.widthAnchor.constraint(equalToConstant: 1),
            verticalLine2.leadingAnchor.constraint(equalTo: scoreStackView.trailingAnchor, constant: 11.5),
            verticalLine2.bottomAnchor.constraint(equalTo: verticalLine1.bottomAnchor),

            withMeStackView.topAnchor.constraint(equalTo: rankingStackView.topAnchor),
            withMeStackView.leadingAnchor.constraint(equalTo: verticalLine2.trailingAnchor, constant: 11.5),
            withMeStackView.bottomAnchor.constraint(equalTo: rankingStackView.bottomAnchor),
            withMeStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        rankingLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        scoreLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        withMeLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        verticalLine1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        verticalLine2.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    }
    
    @objc private func presentTemplateVC() {
        delegate?.didTapTemplateButton()
    }
    
    public func configure(name: String?,
                          rank: Int?,
                          score: Int?,
                          updatedAt: Int64?) {
        
        self.nftName.text = name ?? "N/A"
        self.rankingNumLabel.text = String(rank ?? 0)
        self.scoreNumLabel.text = String(score ?? 0)
        self.withMeNumLabel.text = "D+ " + String(calculateNumberOfDays(since: updatedAt ?? 0))
    }
    
    @objc func changeCardButtonImage(notification: NSNotification) {
        
        let isBack: Bool = notification.object as! Bool
        print("\(#function) ---- \(isBack)")
        self.cardButton.imageView?.image = isBack ? UIImage(named: "back_opensea_button") : UIImage(named: "front_deco_button")
    }
    
    
    private func calculateNumberOfDays(since endDate: Int64) -> Int {
        let currentDate: Int = Int(Date().timeIntervalSince1970)
        let numberOfDays: Int = (currentDate - Int(endDate)) / 3600 / 24
        return numberOfDays
    }
}
