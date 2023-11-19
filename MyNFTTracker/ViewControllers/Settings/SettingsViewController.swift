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
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(name: .appMainFontBold, size: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let walletAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(name: .appMainFontLight, size: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: ImageAssets.clipboardFill)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let settingTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
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
        
        self.bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveSettingsToUserDefaults(self.vm.theme)
    }
}

extension SettingsViewController {
    private func setUI() {
        self.view.addSubview(self.toggleSwitch)
    }
    
    private func setLayout() {
        self.toggleSwitch.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self
    }
}

extension SettingsViewController {
    
    private func bind() {
        self.toggleSwitch.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.vm.theme = $0 ? .white : .black
                self.sendThemeNotification(newTheme: self.vm.theme)
            }
            .store(in: &bindings)
        
        self.vm.$theme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.themeChanged(as: $0)
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
        switch theme {
        case .black:
            self.view.backgroundColor = .black
            self.toggleSwitch.isOn = false
        case .white:
            self.view.backgroundColor = .white
            self.toggleSwitch.isOn = true
        }
    }
    
    func firstBtnTapped() {
        return
    }
    
    func secondBtnTapped() {
        return
    }
}
