//
//  MainViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import SnapKit
import Combine
import Nuke
import Lottie
import SideMenu

final class MainViewController: BaseViewController {
    
    private let vm: MainViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    
    //TODO: Add ProfileImage View & Card Flip & Side Menu
    private var menu: SideMenuNavigationController?
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .frenchie3)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let welcomeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.appFont(name: .appMainFontBold, size: .head)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(NFTCardCell.self, forCellWithReuseIdentifier: NFTCardCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    //MARK: - Init
    init(vm: MainViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateTheme()
        
        self.nftCollectionView.delegate = self
        self.nftCollectionView.dataSource = self
        
        self.bind()
        self.setUI()
        self.setLayout()
        self.setNavigariontBar()
        self.setDelegate()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
    }
    
}

extension MainViewController {
    
    private func bind() {
        
        self.vm.$username
            .sink { [weak self] name in
                guard let `self` = self else { return }
                
                self.welcomeTitle.text = String(localized: "Welcome\n") + name
            }
            .store(in: &bindings)
        
        self.vm.$nfts
            .sink { [weak self] nfts in
                guard let `self` = self else { return }
                
                self.vm.imageStrings = nfts.compactMap {
                    guard let imageString = $0.metadata?.image else {
                        return ""
                    }
                    
                    if imageString.hasPrefix("ipfs://") {
                        return self.vm.buildPinataUrl(from: imageString)
                    }
                    return imageString
                }
                
                DispatchQueue.main.async {
                    self.nftCollectionView.reloadData()
                }
                
            }
            .store(in: &bindings)
    }
    
}

extension MainViewController {
    
    private func setUI() {
        self.view.addSubviews(self.profileImage,
                              self.welcomeTitle,
                              self.nftCollectionView)
    }
    
    private func setLayout() {
        self.profileImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.height.width.equalTo(self.view.frame.size.width / 5)
        }
        
        self.welcomeTitle.snp.makeConstraints {
            $0.top.equalTo(self.profileImage.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.bottom.lessThanOrEqualTo(self.nftCollectionView.snp.top).offset(-20)
        }

        self.nftCollectionView.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.height.equalTo(300)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }
    
    private func setNavigariontBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                                image: UIImage(systemName: "list.bullet"),
                                                                target: self,
                                                                action: #selector(showSideMenu))
    }
    
    @objc private func showSideMenu() {
        
        let rootVC = ContentsSideMenuViewController(vm: ContentsSideMenuViewViewModel())
        rootVC.delegate = self
        
        self.menu = SideMenuNavigationController(rootViewController: rootVC)
        self.menu?.leftSide = true
        
        guard let menu = self.menu else { return }
        present(menu, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.vm.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCardCell.identifier,
                                                            for: indexPath) as? NFTCardCell else {
            fatalError()
        }
        
        // Card Front View
        /*
        if let url = URL(string: self.vm.imageStrings[indexPath.item]) {
            Task {
                do {
                    let image = try await ImagePipeline.shared.image(for: url)
                    
                    DispatchQueue.main.async {
                        cell.configureImage(image: image)
                    }
                }
                catch {
                    print("Error fetching image -- \(error.localizedDescription)")
                }
                
            }
            return cell
        }
        cell.configureImage(image: UIImage(resource: .myNFTTrackerLogo))
         */
        
        // Card Back View
        cell.configureBackView(nft: self.vm.nfts[indexPath.item])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 1.5
        return CGSize(width: width, height: width)
    }
    
}

extension MainViewController {
    private func updateTheme() {
        guard let themeString = UserDefaults.standard.string(forKey: UserDefaultsConstants.theme),
              let theme = Theme(rawValue: themeString)
        else {
            self.themeChanged(as: .black)
            return
        }
        
        self.themeChanged(as: theme)
    }
}

extension MainViewController: BaseViewControllerDelegate {
    func themeChanged(as theme: Theme) {
        switch theme {
        case .black:
            self.view.backgroundColor = .black
        case .white:
            self.view.backgroundColor = .white
        }
    }
    
    func firstBtnTapped() {
        return
    }
    
    func secondBtnTapped() {
        return
    }
}

extension MainViewController: ContentsSideMenuViewDelegate {
    func menuDidSelected(_ menu: ContentsSideMenuViewViewModel.Contents) {
        self.menu?.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            
            switch menu {
            case .main:
                return
            case .settings:
                self.show(SettingsViewController(vm: SettingsViewViewModel()), sender: nil)
            }
        }

    }
}


