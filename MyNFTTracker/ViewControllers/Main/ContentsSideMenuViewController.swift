//
//  ContentsSideMenuViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import UIKit
import Combine
import SnapKit

protocol ContentsSideMenuViewDelegate: AnyObject {
    func menuDidSelected(_ menu: ContentsSideMenuViewViewModel.Contents)
    func signoutDidSelected(_ viewController: ContentsSideMenuViewController)
}

final class ContentsSideMenuViewController: BaseViewController {
    
    private var vm: ContentsSideMenuViewViewModel
    
    weak var delegate: ContentsSideMenuViewDelegate?
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.text = SideMenuConstants.menu
        label.font = .appFont(name: .appMainFontBold, size: .head)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentsTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: UITableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let signoutButton: UIButton = {
       let button = UIButton()
        button.setTitle(SideMenuConstants.signout, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .appFont(name: .appMainFontMedium, size: .light)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(vm: ContentsSideMenuViewViewModel) {
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
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.bind()
    }
    
    deinit {
        print("Denit")
    }
    
}

extension ContentsSideMenuViewController {
    private func bind() {
        self.signoutButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.signOutDidTap()
            }
            .store(in: &self.bindings)
    }
    
    private func signOutDidTap() {
        let alert = UIAlertController(title: SideMenuConstants.signout,
                                      message: SideMenuConstants.signoutMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: SideMenuConstants.signout,
            style: .destructive,
            handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.signoutDidSelected(self)
            }))
        
        alert.addAction(UIAlertAction(
            title: SideMenuConstants.cancel,
            style: .cancel,
            handler: nil))
        
        self.present(alert, animated: true)
    }
}

extension ContentsSideMenuViewController {
    private func setUI() {
        self.view.addSubviews(self.menuLabel,
                              self.contentsTable,
                              self.signoutButton)
    }
    
    private func setLayout() {
        self.menuLabel.snp.makeConstraints {
            $0.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        self.contentsTable.snp.makeConstraints {
            $0.top.equalTo(self.menuLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.signoutButton.snp.top).offset(-10)
        }
        self.signoutButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.contentsTable.snp.bottom).offset(10)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setDelegate() {
        self.baseDelegate = self
        self.contentsTable.delegate = self
        self.contentsTable.dataSource = self
    }
}

extension ContentsSideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.vm.menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier,
                                                 for: indexPath)
        cell.backgroundColor = .clear
        var config = cell.defaultContentConfiguration()
        config.text = self.vm.menuList[indexPath.row].displayText
        
        var textColor: UIColor?
        if let themeString = UserDefaults.standard.string(forKey: UserDefaultsConstants.theme),
           let theme = Theme(rawValue: themeString) {
            switch theme {
            case .black:
                textColor = AppColors.DarkMode.text
            case .white:
                textColor = AppColors.LightMode.text
            }
        }

        config.textProperties.color = textColor ?? AppColors.DarkMode.text
    
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuDidSelected(self.vm.menuList[indexPath.row])
    }
}

extension ContentsSideMenuViewController {
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

extension ContentsSideMenuViewController: BaseViewControllerDelegate {

    func themeChanged(as theme: Theme) {
        var textColor: UIColor?
        
        switch theme {
        case .black:
            self.view.backgroundColor = AppColors.DarkMode.secondaryBackground.withAlphaComponent(0.8)
            textColor = AppColors.DarkMode.text
        case .white:
            self.view.backgroundColor = AppColors.LightMode.secondaryBackground.withAlphaComponent(0.8)
            textColor = AppColors.LightMode.text
        }
        self.menuLabel.textColor = textColor
        self.signoutButton.setTitleColor(textColor, for: .normal)
    }
    
    func userInfoChanged(as user: User) {
        return
    }
    
}
