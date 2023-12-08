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

protocol MainViewControllerDelegate: AnyObject {
    func errorDidReceive(_ viewController: UIViewController, error: Error)
}

final class MainViewController: BaseViewController {
    
    weak var delegate: MainViewControllerDelegate?
    
    private let vm: MainViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    typealias Handler = () -> Void
    
    //MARK: - UI Elements
    private var menu: SideMenuNavigationController?
    
    private let loadingVC = LoadingViewController()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let welcomeTitle: UILabel = {
        let label = UILabel()
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
    
    private let noNftCardView: NoNFTCardView = {
        let view = NoNFTCardView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        self.bind()
        self.setUI()
        self.setLayout()
        self.setNavigariontBar()
        self.setDelegate()

        self.addChildViewController(self.loadingVC)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
    }
    
}

extension MainViewController {
    
    private func bind() {

        self.vm.user
            .sink { [weak self] error in
                guard let `self` = self else { return }
                switch error {
                case .finished:
                    return
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.showLoginViewController {
                            self.delegate?.errorDidReceive(self, error: err)
                        }
                    }
                }
            } receiveValue: { [weak self] in
                guard let `self` = self,
                      let user = $0 else { return }
                self.vm.currentUserInfo = user
                self.vm.username = user.nickname
                self.vm.profileImageDataString = user.imageData

            }
            .store(in: &bindings)
        
        self.vm.$username
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let `self` = self else { return }
                print("Username: \(name)")
                DispatchQueue.main.async {
                    self.welcomeTitle.text = String(format: MainViewConstants.welcome, name)
                }
                
            }
            .store(in: &bindings)
        
        self.vm.$profileImageDataString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData in
                guard let `self` = self,
                      let dataString = imageData else { return }
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage.convertBase64StringToImage(dataString)
                }
            }
            .store(in: &bindings)
        
        
        self.vm.$nfts
            .sink { [weak self] nfts in
                guard let `self` = self else { return }
                
                if nfts.isEmpty {
                    DispatchQueue.main.async {
                        self.nftCollectionView.isHidden = true
                        self.noNftCardView.isHidden = false
                        self.loadingVC.removeViewController()
                    }
                } else {
                    
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
                        self.nftCollectionView.isHidden = false
                        self.noNftCardView.isHidden = true
                        self.nftCollectionView.reloadData()
                        self.loadingVC.removeViewController()
                    }
                }
                
            }
            .store(in: &bindings)
    }
    
}

extension MainViewController {
    
    private func setUI() {
        self.view.addSubviews(self.profileImage,
                              self.welcomeTitle,
                              self.nftCollectionView,
                              self.noNftCardView)
    }
    
    private func setLayout() {
        self.profileImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.height.width.equalTo(self.view.frame.size.width / 5)
        }
        
        self.welcomeTitle.snp.makeConstraints {
            $0.top.equalTo(self.profileImage.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.bottom.lessThanOrEqualTo(self.nftCollectionView.snp.top).offset(-20)
        }

        self.nftCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.welcomeTitle.snp.bottom).offset(50)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-5)
            $0.height.equalTo(300)
        }
        
        self.noNftCardView.snp.makeConstraints {
            $0.edges.equalTo(self.nftCollectionView)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self
        self.nftCollectionView.delegate = self
        self.nftCollectionView.dataSource = self
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
        
        cell.resetCell()
        
        let isHidden = vm.selectedNfts[indexPath.row]
        
        // Card Back View
        cell.configureBack(with: self.vm.nfts[indexPath.item], isHidden: !isHidden)
        
        // Card Front View
        guard let url = URL(string: self.vm.imageStrings[indexPath.item]) else {
            cell.configureFront(with: UIImage(resource: .myNFTTrackerLogo), isHidden: isHidden)
            return cell
        }
        
        Task {
            do {
                let image = try await ImagePipeline.shared.image(for: url)
                
                DispatchQueue.main.async {
                    cell.configureFront(with: image, isHidden: isHidden)
                }
            }
            catch {
                print("Error fetching image -- \(error.localizedDescription)")
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NFTCardCell else {
            fatalError()
        }
        vm.selectedNfts[indexPath.row].toggle()
        
        let hideFront = vm.selectedNfts[indexPath.row] ? true : false
        cell.toggleToHide(front: hideFront, back: !hideFront)
        
        let viewToHide = hideFront ? cell.cardFrontView : cell.cardBackView
        let viewToShow = hideFront ? cell.cardBackView : cell.cardFrontView
        
        UIView.transition(from: viewToHide,
                          to: viewToShow,
                          duration: 0.3,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 1.3
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
        var gradientUpperColor: UIColor?
        var gradientLowerColor: UIColor?
        var textColor: UIColor?
        var borderColor: UIColor?
        var tintColor: UIColor?
        
        switch theme {
        case .black:
            gradientUpperColor = AppColors.DarkMode.gradientUpper
            gradientLowerColor = AppColors.DarkMode.gradientLower
            textColor = AppColors.DarkMode.text
            borderColor = AppColors.DarkMode.border
            tintColor = .white
        case .white:
            gradientUpperColor = AppColors.LightMode.gradientUpper
            gradientLowerColor = AppColors.LightMode.gradientLower
            textColor = AppColors.LightMode.text
            borderColor = AppColors.LightMode.border
            tintColor = .black
        }
        
        let gradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                                                  colors: [gradientUpperColor!,
                                                           gradientLowerColor!])
        self.view.backgroundColor = UIColor(patternImage: gradientImage)
        
        self.welcomeTitle.textColor = textColor
        self.profileImage.layer.borderColor = borderColor?.cgColor
        
        self.noNftCardView.configure(textColor: textColor, imageColor: tintColor)
    }

    func userInfoChanged(as user: User) {
        self.vm.user.send(user)
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
                guard let user = self.vm.currentUserInfo else { return }
                self.show(
                    SettingsViewController(
                        vm: SettingsViewViewModel(
                            userInfo: user
                        )
                    ),
                    sender: nil
                )
            }
        }

    }
    
    func signoutDidSelected(_ viewController: ContentsSideMenuViewController) {
        self.menu?.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            
            UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.walletAddress)
            MetamaskManager.shared.metaMaskSDK.disconnect()
            
            self.showLoginViewController()
        }
    }
    
    private func showLoginViewController(completion: Handler? = nil) {
        let vcs = self.navigationController?.viewControllers
        let loginVC = vcs?.filter({ vc in
            vc is LoginViewController
        }).first as? LoginViewController
        
        guard let loginVC = loginVC else {

            self.dismiss(animated: true) { [weak self] in
                guard let `self` = self else { return }
                let loginVM = LoginViewViewModel()
                let loginVC = LoginViewController(vm: loginVM)
                self.delegate = loginVC
                self.navigationController?.setViewControllers([loginVC], animated: true)
                completion?()
            }
            return
        }
        self.navigationController?.popToViewController(loginVC, animated: true)
    }
}


