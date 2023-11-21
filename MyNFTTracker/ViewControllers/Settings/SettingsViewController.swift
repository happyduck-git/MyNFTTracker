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
    
    private let copyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: ImageAssets.clipboardFill)
        return imageView
    }()
    
    private let settingTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
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
            $0.width.height.equalTo(self.view.frame.width / 6)
        }
        
        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.addressStack.snp.makeConstraints {
            $0.top.equalTo(self.nicknameLabel.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        self.copyIcon.snp.makeConstraints {
            $0.width.equalTo(self.copyIcon.snp.height)
        }
        
        self.settingTableView.snp.makeConstraints {
            $0.top.equalTo(self.copyIcon.snp.bottom)
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
        var bgColor: UIColor = .white
        var elementsColor: UIColor = .black
        var isOn: Bool = false
        
        switch theme {
        case .black:
            bgColor = .black
            elementsColor = .white
            isOn = false
        case .white:
            bgColor = .white
            elementsColor = .black
            isOn = true
        }
        
        self.view.backgroundColor = bgColor
        self.nicknameLabel.textColor = elementsColor
        self.walletAddressLabel.textColor = elementsColor
        self.copyIcon.tintColor = elementsColor
        self.settingTableView.backgroundColor = bgColor
        
        self.toggleSwitch.isOn = isOn
        
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
        return self.vm.settingContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = self.vm.settingContents[indexPath.row].sectionTitle
        
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.vm.settingContents[section].sectionTitle
    }
    
}
