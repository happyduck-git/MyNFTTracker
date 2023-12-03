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
        label.text = "0x0000000000"
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
    
    private let settingTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(ToggleCell.self, forCellReuseIdentifier: ToggleCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "Select Theme")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggler = UISwitch()
        toggler.isOn = false
        toggler.translatesAutoresizingMaskIntoConstraints = false
        return toggler
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
        
        self.bind()
        
        DispatchQueue.main.async {
            self.profileImageView.circleView()
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveSettingsToUserDefaults(self.vm.theme)
    }
}

extension SettingsViewController {
    private func setUI() {
        self.view.addSubviews(self.profileImageView,
                              self.nicknameLabel,
                              self.addressStack,
                              self.settingTableView)
        
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
        
        self.settingTableView.snp.makeConstraints {
            $0.top.equalTo(self.copyIcon.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self

        self.settingTableView.dataSource = self
        self.settingTableView.delegate = self
    }
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Edit"), menu: nil)
    }
}

extension SettingsViewController {
    
    private func bind() {
        self.vm.$theme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.themeChanged(as: $0)
                self.settingTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            .store(in: &bindings)
        
        self.vm.$userInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.nicknameLabel.text = $0.nickname
            }
            .store(in: &bindings)
        
        self.vm.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.profileImageView.image = $0
            }
            .store(in: &bindings)
        
        self.vm.$walletAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.walletAddressLabel.text = $0
            }
            .store(in: &bindings)
        
        self.copyIcon.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if !self.vm.clipboardTapped {
                    self.vm.clipboardTapped = true
                }
            }
            .store(in: &bindings)
        
        self.vm.$clipboardTapped
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tapped in
                if tapped {
                    guard let `self` = self else { return }
                    
                    UIPasteboard.general.string = self.vm.walletAddress
                    #if DEBUG
                    AppLogger.logger.debug("Address Copied to Clipboard: \(self.vm.walletAddress)")
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
        
        switch theme {
        case .black:
            bgColor = AppColors.DarkMode.secondaryBackground
            elementsColor = AppColors.DarkMode.text
            
        case .white:
            bgColor = AppColors.LightMode.secondaryBackground
            elementsColor = AppColors.LightMode.text
        }
        
        self.view.backgroundColor = bgColor
        self.nicknameLabel.textColor = elementsColor
        self.walletAddressLabel.textColor = elementsColor
        self.copyIcon.tintColor = elementsColor
        self.settingTableView.backgroundColor = bgColor

    }
    
    func firstBtnTapped() {
        return
    }
    
    func secondBtnTapped() {
        return
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
