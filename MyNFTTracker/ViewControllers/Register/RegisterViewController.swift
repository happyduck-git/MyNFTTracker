//
//  RegisterViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import UIKit
import SnapKit
import Combine

final class RegisterViewController: BaseViewController {

    let vm: RegisterViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = String(localized: "프로필 이미지와 닉네임을 설정해보세요.")
        label.font = .appFont(name: .appMainFontLight, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: ImageAssets.editFill)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = String(localized: "닉네임")
        label.font = .appFont(name: .appMainFontMedium, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
       let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(String(localized: "저장하기"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = String(localized: "\"설정\"에서 추후 변경 가능합니다.")
        label.font = .appFont(name: .appMainFontLight, size: .light)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.setNavigationBarItem()
        self.bind()
        
        self.activateSaveButton(false)
        self.nicknameTextField.placeholder = self.vm.walletAddres
        
        self.dismissKeyboard()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.profileView.layer.cornerRadius = self.profileView.frame.width / 2
        }
    }

    //MARK: - Init
    init(vm: RegisterViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RegisterViewController {
    private func setUI() {
        self.view.addSubviews(self.descriptionLabel,
                              self.profileView,
                              self.editButton,
                              self.nicknameLabel,
                              self.nicknameTextField,
                              self.infoLabel,
                              self.saveButton)
    }
    
    private func setLayout() {
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            
        }
        self.profileView.snp.makeConstraints {
            $0.top.equalTo(self.descriptionLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(self.view.frame.width / 4)
        }
        
        self.editButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(self.profileView)
            $0.width.height.equalTo(20)
        }
        
        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(50)
        }
        
        self.nicknameTextField.snp.makeConstraints {
            $0.centerY.equalTo(self.nicknameLabel.snp.centerY)
            $0.leading.equalTo(self.nicknameLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
        }
        
        self.infoLabel.snp.makeConstraints {
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-50)
        }
        
        self.saveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        self.profileView.layer.borderWidth = 1
        self.saveButton.layer.cornerRadius = 10
        
        nicknameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }
}

extension RegisterViewController {
    func bind() {
        
        self.nicknameTextField.textPublisher
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .removeDuplicates()
            .sink { [weak self] text in
                guard let `self` = self else { return }
                self.vm.nickname = text
            }
            .store(in: &bindings)
        
        self.editButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if self.vm.canShowPickerView {
                    self.vm.showPickerView = true
                }
            }
            .store(in: &bindings)
        
        self.saveButton.tapPublisher
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.saveUserInfo(of: self.vm.walletAddres,
                                  username: self.vm.nickname,
                                  imageData: self.vm.profileImage?.pngData()?.base64EncodedString() ?? "no-image")
            }
            .store(in: &bindings)
        
        self.vm.$showPickerView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let `self` = self,
                let show = show
                else { return }
                
                if show {
                    self.vm.canShowPickerView = false
                    self.showAvatarPicker()
                }
            }
            .store(in: &bindings)
        
        self.vm.$appTheme
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                guard let `self` = self else { return }
                self.themeChanged(as: theme)
            }
            .store(in: &bindings)
        
        self.vm.$nickname
            .removeDuplicates()
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.vm.isNicknameFilled = $0.isEmpty ? false : true
            }
            .store(in: &bindings)
        
        self.vm.$isNicknameFilled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.activateSaveButton($0)
            }
            .store(in: &bindings)
        
        self.vm.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let `self` = self else { return }
                self.profileView.image = image
            }
            .store(in: &bindings)
        
    }
}

extension RegisterViewController {
    private func setNavigationBarItem() {
        let rightBarButtonItem = UIBarButtonItem(
            title: RegisterViewConstants.skip,
            style: .plain,
            target: self,
            action: #selector(skipDidTap(_:)))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func skipDidTap(_ sender: UIBarButtonItem) {
        self.saveUserInfo(of: self.vm.walletAddres,
                          username: self.vm.walletAddres,
                          imageData: self.vm.profileImage?.pngData()?.base64EncodedString() ?? "no-image")
    
    }
    
    private func saveUserInfo(of address: String, username: String, imageData: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.addChildViewController(self.loadingVC)
        }
        Task {
            await self.vm.saveUserInfo(of: address,
                                 username: username,
                                 imageUrl: imageData)
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.loadingVC.removeViewController()
                self.show(MainViewController(vm: MainViewViewModel()), sender: self)
            }
        }
    }
}

extension RegisterViewController: BaseViewControllerDelegate {
    func firstBtnTapped() {
        return
    }
    
    func secondBtnTapped() {
        return
    }
    
    func themeChanged(as theme: Theme) {
        
        var gradientUpperColor: UIColor?
        var gradientLowerColor: UIColor?
        var textColor: UIColor?
        var buttonColor: UIColor?
        var borderColor: UIColor?
        
        switch theme {
        case .black:
            gradientUpperColor = AppColors.DarkMode.gradientUpper
            gradientLowerColor = AppColors.DarkMode.gradientLower
            textColor = AppColors.DarkMode.text
            buttonColor = self.vm.isNicknameFilled ? AppColors.DarkMode.buttonActive : AppColors.DarkMode.buttonInactive
            borderColor = AppColors.DarkMode.border
            
        case .white:
            gradientUpperColor = AppColors.LightMode.gradientUpper
            gradientLowerColor = AppColors.LightMode.gradientLower
            textColor = AppColors.LightMode.text
            buttonColor = self.vm.isNicknameFilled ? AppColors.LightMode.buttonActive : AppColors.LightMode.buttonInactive
            borderColor = AppColors.LightMode.border
        }
        
        let gradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                                                  colors: [gradientUpperColor!,
                                                           gradientLowerColor!])
        self.view.backgroundColor = UIColor(patternImage: gradientImage)
        
        self.descriptionLabel.textColor = textColor
        self.nicknameLabel.textColor = textColor
        self.saveButton.backgroundColor = buttonColor
        self.saveButton.layer.borderColor = borderColor?.cgColor
        self.saveButton.setTitleColor(textColor, for: .normal)
        
    }
        
}

extension RegisterViewController {
   
    private func activateSaveButton(_ status: Bool) {
        self.saveButton.isUserInteractionEnabled = status
        var color: UIColor?
        
        switch self.vm.appTheme {
        case .black:
            color = status ? AppColors.DarkMode.buttonActive : AppColors.DarkMode.buttonInactive
        case .white:
            color = status ? AppColors.LightMode.buttonActive : AppColors.LightMode.buttonInactive
        }
        
        self.saveButton.backgroundColor = color
    }
    
    private func showAvatarPicker() {
        let vm = AvatarCollectionViewViewModel(selectedCell: self.vm.selectedAvatarIndex)
        let viewControllerToPresent = AvatarCollectionViewController(vm: vm, delegate: self)
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.delegate = self
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
}

extension RegisterViewController: AvatarCollectionViewControllerDelegate {
    
    func avatarCollectionViewController(_ avatarCollectionViewController: AvatarCollectionViewController,
                                        didSelectAvatar avatar: UIImage?,
                                        at indexPath: IndexPath) {
        self.profileView.image = avatar
        self.vm.selectedAvatarIndex = indexPath
    }
    
    
}

extension RegisterViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.vm.showPickerView = false
        self.vm.canShowPickerView = true
    }
}