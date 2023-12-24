//
//  EditViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import UIKit
import Combine
import SnapKit

final class EditViewController: BaseViewController {
    
    private let vm: EditViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    private let loadingVC = LoadingViewController()
    
    private var avatarBottomVC: AvatarCollectionViewController?
    
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
        label.text = EditConstants.nickname
        label.font = .appFont(name: .appMainFontMedium, size: .plain)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.font = .appFont(name: .appMainFontMedium, size: .plain)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
       let button = UIButton()
        button.setTitle(EditConstants.save, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.bind()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.profileView.layer.cornerRadius = self.profileView.frame.width / 2
        }
        
        self.dismissKeyboard()
    }
    
    //MARK: - Init
    init(vm: EditViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        guard let bottomVC = self.avatarBottomVC else { return }
        bottomVC.dismiss(animated: true)
    }
}

extension EditViewController {
    private func bind() {
        self.vm.$theme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                guard let `self` = self else { return }
                self.themeChanged(as: theme)
            }
            .store(in: &bindings)
        
        self.vm.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let `self` = self else { return }
                self.vm.address = user.address
                self.vm.nickname = user.nickname
                self.vm.profileImageDataString = user.imageData
                
                self.nicknameTextField.text = user.nickname
                self.profileView.image = UIImage.convertBase64StringToImage(user.imageData)
            }
            .store(in: &bindings)
        
        self.vm.$newNickname
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.vm.isNicknameChanged = ($0 != self.vm.nickname) ? true : false
            }
            .store(in: &bindings)
        
        self.vm.$newProfileImageDataString
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.vm.isProfileChanged = ($0 != self.vm.profileImageDataString) ? true : false
            }
            .store(in: &bindings)
        
        self.vm.infoChanged
            .sink { [weak self] in
                guard let `self` = self else { return }
                print("Info change detected")
                self.activateSaveButton($0)
            }
            .store(in: &bindings)
        
        self.nicknameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.vm.newNickname = $0
            }
            .store(in: &bindings)
        
        self.editButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.showAvatarPicker()
            }
            .store(in: &bindings)
        
        self.saveButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.showUpdateConfirmAlert()
            }
            .store(in: &bindings)
    }
}

extension EditViewController {
    private func setUI() {
        self.view.addSubviews(self.profileView,
                              self.editButton,
                              self.nicknameLabel,
                              self.nicknameTextField,
                              self.saveButton)
    }
    
    private func setLayout() {
        self.profileView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
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
            $0.trailing.equalTo(self.nicknameTextField.snp.leading).offset(-50)
        }
        
        self.nicknameTextField.snp.makeConstraints {
            $0.centerY.equalTo(self.nicknameLabel)
            $0.height.equalTo(30)
            $0.trailing.equalToSuperview().offset(-50)
        }
        
        self.saveButton.snp.makeConstraints {
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.view.frame.width / 4)
            $0.height.equalTo(40)
            $0.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-50)
        }
        
        nicknameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }
}

extension EditViewController: BaseViewControllerDelegate {
    
    func themeChanged(as theme: Theme) {
        var bgColor: UIColor?
        var textColor: UIColor?
        var borderColor: UIColor?
        
        switch theme {
        case .black:
            bgColor = AppColors.DarkMode.secondaryBackground
            textColor = AppColors.DarkMode.text
            borderColor = AppColors.DarkMode.border
            
        case .white:
            bgColor = AppColors.LightMode.secondaryBackground
            textColor = AppColors.LightMode.text
            borderColor = AppColors.LightMode.border
        }

        self.view.backgroundColor = bgColor
        self.nicknameLabel.textColor = textColor
        self.profileView.layer.borderColor = borderColor?.cgColor

    }
    
    func userInfoChanged(as user: User) {
        self.vm.user = user
    }
}

extension EditViewController: AvatarCollectionViewControllerDelegate, UISheetPresentationControllerDelegate {
    private func showAvatarPicker() {
        let vm = AvatarCollectionViewViewModel(selectedCell: self.vm.selectedAvatarIndex)
        self.avatarBottomVC = AvatarCollectionViewController(vm: vm, delegate: self)
        guard let bottomVC = self.avatarBottomVC else { return }
        if let sheet = bottomVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.delegate = self
        }
        present(bottomVC, animated: true, completion: nil)
    }
    
    func avatarCollectionViewController(_ avatarCollectionViewController: AvatarCollectionViewController,
                                        didSelectAvatar avatar: UIImage?,
                                        at indexPath: IndexPath) {
        self.vm.selectedAvatarIndex = indexPath
        self.vm.newProfileImageDataString = avatar?.pngData()?.base64EncodedString()
        self.profileView.image = avatar
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.vm.showPickerView = false
        self.vm.canShowPickerView = true
    }
}

extension EditViewController {
    private func activateSaveButton(_ status: Bool) {
        self.saveButton.isUserInteractionEnabled = status
        var color: UIColor?
        
        switch self.vm.theme {
        case .black:
            color = status ? AppColors.DarkMode.buttonActive : AppColors.DarkMode.buttonInactive
        case .white:
            color = status ? AppColors.LightMode.buttonActive : AppColors.LightMode.buttonInactive
        }
        
        self.saveButton.backgroundColor = color
    }
    
    private func showUpdateCompleteAlert() {
        let alert = UIAlertController(title: EditConstants.updateCompleted,
                                      message: EditConstants.updateCompletedMsg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: EditConstants.confirm, style: .default))
        
        self.present(alert, animated: true)
    }
    
    private func showUpdateConfirmAlert() {
        let alert = UIAlertController(title: EditConstants.updateConfirm,
                                      message: EditConstants.updateConfirmMsg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: EditConstants.confirm, style: .default) {
            _ in
            self.addChildViewController(self.loadingVC)
            
            Task {
                do {
                    try await self.vm.updateUserInfo()
                    
                    Task.detached {
                        do {
                            let user = try await FirestoreManager.shared.retrieveUserInfo(of: self.vm.user.address ?? "no-address")
                            self.vm.user = user
                            NotificationCenter.default.post(name: NSNotification.Name(NotificationConstants.userInfo),
                                                            object: user)
                        } catch {
                            AppLogger.logger.error("Error retrieving user info: \(error)")
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let `self` = self else { return }
                        self.loadingVC.removeViewController()
                        self.navigationController?.popViewController(animated: true)
                        #if DEBUG
                        AppLogger.logger.info("UserInfo update complete")
                        #endif
                    }
                }
                catch {
                    AppLogger.logger.error("Error updating user info to firestore -- \(error)")
                }
                
            }
        })
        alert.addAction(UIAlertAction(title: EditConstants.cancel, style: .destructive))
        
        self.present(alert, animated: true)
    }
}

extension EditViewController {
    private func sendUserInfoUpdateNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationConstants.userInfo),
                                        object: nil)
    }
}
