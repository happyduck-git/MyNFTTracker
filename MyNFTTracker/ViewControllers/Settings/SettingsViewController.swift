//
//  SettingsViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import UIKit
import Combine

final class SettingsViewController: BaseViewController {

    private var vm: SettingsViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private var snackbar: SnackBarView?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nickname"
        label.lineBreakMode = .byTruncatingMiddle
        label.textAlignment = .center
        label.textColor = .label
        label.font = .appFont(name: .appMainFontBold, size: .head)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let walletAddressLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        label.lineBreakMode = .byTruncatingMiddle
        label.textAlignment = .center
        label.font = .appFont(name: .appMainFontLight, size: .plain)
        return label
    }()
    
    private let copyIcon: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: ImageAssets.clipboardFill), for: .normal)
        return button
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = String(localized: "테마 선택하기")
        label.font = .appFont(name: .appMainFontLight, size: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var darkThemeButton: AppThemeButton = {
        let button = AppThemeButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lightThemeButton: AppThemeButton = {
        let button = AppThemeButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Init
    init(vm: SettingsViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.setNavigationBar()
        self.configureThemeButtons()
        
        self.bind()
        
        DispatchQueue.main.async {
            self.profileImageView.circleView()
        }
        
    }

}

extension SettingsViewController {
    private func setUI() {
        self.view.addSubviews(self.profileImageView,
                              self.nicknameLabel,
                              self.addressStack,
                              self.themeLabel,
                              self.divider,
                              self.darkThemeButton,
                              self.lightThemeButton)
        
        self.addressStack.addArrangedSubviews(self.walletAddressLabel,
                                              self.copyIcon)
    }
    
    private func setLayout() {
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.height.equalTo(self.view.frame.width / 4)
        }
        
        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.addressStack.snp.makeConstraints {
            $0.top.equalTo(self.nicknameLabel.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(60)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
        }
        
        self.copyIcon.snp.makeConstraints {
            $0.width.equalTo(self.copyIcon.snp.height)
        }
        
        self.themeLabel.snp.makeConstraints {
            $0.top.equalTo(self.addressStack.snp.bottom).offset(50)
            $0.leading.trailing.equalTo(self.nicknameLabel)
        }
        
        self.divider.snp.makeConstraints {
            $0.top.equalTo(self.themeLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.nicknameLabel)
            $0.height.equalTo(2)
        }

        self.darkThemeButton.snp.makeConstraints {
            $0.top.equalTo(self.divider.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(self.view.frame.height / 2.5)
            $0.width.equalTo((self.view.frame.width - 60) / 2)
            $0.bottom.lessThanOrEqualToSuperview().offset(-50)
        }
        
        self.lightThemeButton.snp.makeConstraints {
            $0.top.bottom.equalTo(self.darkThemeButton)
            $0.leading.equalTo(self.darkThemeButton.snp.trailing).offset(10)
            $0.height.equalTo(self.darkThemeButton.snp.height)
            $0.width.equalTo(self.darkThemeButton.snp.width)
        }
        self.darkThemeButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.lightThemeButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: SettingsConstants.edit,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(editDidTap(_:)))
    }
    
    @objc private func editDidTap(_ sender: UIBarButtonItem) {
        let vm = EditViewViewModel(userInfo: self.vm.user)
        let vc = EditViewController(vm: vm)
        self.show(vc, sender: nil)
    }
    
    private func configureThemeButtons() {
        let darkGradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                                                      colors: [AppColors.DarkMode.gradientUpper,
                                                               AppColors.DarkMode.gradientLower])
        let lightGradientImage = UIImage.gradientImage(bounds: self.view.bounds,
                                                      colors: [AppColors.LightMode.gradientUpper,
                                                               AppColors.LightMode.gradientLower])
        
        self.darkThemeButton.configure(image: darkGradientImage, title: SettingsConstants.darkMode)
        self.lightThemeButton.configure(image: lightGradientImage, title: SettingsConstants.lightMode)
    }
}

extension SettingsViewController {
    
    private func bind() {
        self.vm.$theme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.themeChanged(as: $0)
            }
            .store(in: &bindings)
        
        self.vm.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.nicknameLabel.text = $0.nickname
                self.walletAddressLabel.text = $0.address ?? "no-address"
                self.profileImageView.image = UIImage.convertBase64StringToImage($0.imageData)
            }
            .store(in: &bindings)
        
        self.vm.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.profileImageView.image = $0
            }
            .store(in: &bindings)
        
        self.vm.$clipboardTapped
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tapped in
                if tapped {
                    guard let `self` = self else { return }
                    
                    UIPasteboard.general.string = self.vm.user.address ?? "no-address"
                    #if DEBUG
                    AppLogger.logger.debug("Address Copied to Clipboard: \(self.vm.user.address ?? "no-address")")
                    #endif
                    
                    self.addSnackbar()
                    guard let snackbar = self.snackbar else { return }
                    self.showSnackbar(snackbar: snackbar, vm: self.vm)
                    
                    self.vm.clipboardTapped = false
                } else {
                    return
                }
            }
            .store(in: &bindings)
        
        self.vm.themeChangedTo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                var selectDark = false
                var selectLight = false
                switch $0 {
                case .black:
                    selectDark = true
                case .white:
                    selectLight = true
                }
                self.darkThemeButton.toggleButton(selectDark)
                self.lightThemeButton.toggleButton(selectLight)
                
                self.vm.theme = $0
                self.sendThemeNotification(newTheme: self.vm.theme)
                self.saveSettingsToUserDefaults(self.vm.theme)
            }
            .store(in: &bindings)
        
        self.copyIcon.tapPublisher
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if !self.vm.clipboardTapped {
                    self.vm.clipboardTapped = true
                }
            }
            .store(in: &bindings)
        
        self.darkThemeButton.tapPublisher
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.vm.themeChangedTo.send(.black)
            }
            .store(in: &bindings)
        
        self.lightThemeButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.vm.themeChangedTo.send(.white)
            }
            .store(in: &bindings)
        
    }
    
}

extension SettingsViewController {
    private func saveSettingsToUserDefaults(_ theme: Theme) {
        UserDefaults.standard.set(theme.rawValue,
                                  forKey: UserDefaultsConstants.theme)
    }
}

extension SettingsViewController {
    private func sendThemeNotification(newTheme: Theme) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationConstants.theme),
                                        object: newTheme)
    }
}

extension SettingsViewController: BaseViewControllerDelegate {

    func themeChanged(as theme: Theme) {
        var bgColor: UIColor?
        var elementsColor: UIColor?
        var lableBgColor: UIColor?
        var selectDark = false
        var selectLight = false
        
        switch theme {
        case .black:
            bgColor = AppColors.DarkMode.secondaryBackground
            elementsColor = AppColors.DarkMode.text
            lableBgColor = .darkGray
            selectDark = true
        case .white:
            bgColor = AppColors.LightMode.secondaryBackground
            elementsColor = AppColors.LightMode.text
            lableBgColor = .systemGray5
            selectLight = true
        }
        
        self.view.backgroundColor = bgColor
        self.nicknameLabel.textColor = elementsColor
        self.walletAddressLabel.textColor = elementsColor
        self.copyIcon.tintColor = elementsColor
        self.themeLabel.textColor = elementsColor?.withAlphaComponent(0.7)
        self.divider.backgroundColor = elementsColor?.withAlphaComponent(0.7)
        self.darkThemeButton.configureTextColor(with: elementsColor)
        self.lightThemeButton.configureTextColor(with: elementsColor)
        self.walletAddressLabel.backgroundColor = lableBgColor
        
        self.darkThemeButton.toggleButton(selectDark)
        self.lightThemeButton.toggleButton(selectLight)
    }
    
    func userInfoChanged(as user: User) {
        self.vm.user = user
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToggleCell.identifier, for: indexPath) as? ToggleCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let isOn = (self.vm.theme == .black) ? false : true
        let modeText = (self.vm.theme == .black) ? SettingsConstants.darkMode : SettingsConstants.lightMode
        cell.configure(text: modeText,
                       isOn: isOn)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.vm.sections[section].sectionTitle
    }
    
}

extension SettingsViewController: ToggleCellDelegate {
    func didToggle(_ isOn: Bool) {
        self.vm.theme = isOn ? .white : .black
        self.sendThemeNotification(newTheme: self.vm.theme)
        self.saveSettingsToUserDefaults(self.vm.theme)
    }
}

extension SettingsViewController {
    
    func addSnackbar() {
        let hander = {
            print("Snackbar Initialted.")
        }
        let snackVM = SnackbarViewViewModel(type: .action(handler: hander),
                                            text: String(localized: "클립보드에 복사되었습니다."))
        
        let snackbar = SnackBarView(vm: snackVM)
        snackbar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width/1.5, height: 60)
        self.snackbar = snackbar
        self.view.addSubview(snackbar)
        
    }
    
    func showSnackbar(snackbar: SnackBarView, vm: SettingsViewViewModel) {
        let width = view.frame.size.width/1.5
        
        // Starting point of snackbar
        snackbar.frame = CGRect(x: (view.frame.size.width - width) / 2,
                                y: view.frame.size.height,
                                width: width,
                                height: 60)
        
        // Animate to up: Change the 'y' position.
       
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let `self` = self else { return }
            
            snackbar.frame = CGRect(x: (view.frame.size.width - width) / 2,
                                    y: view.frame.size.height - 100,
                                    width: width,
                                    height: 60)
        } completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 0.5) { [weak self] in
                        guard let `self` = self else { return }
                        
                        snackbar.frame = CGRect(x: (view.frame.size.width - width) / 2,
                                                y: view.frame.size.height,
                                                width: width,
                                                height: 60)
                    }
      
                }
                
            }
        }

    }
}
