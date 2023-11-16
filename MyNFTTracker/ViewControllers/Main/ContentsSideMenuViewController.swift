//
//  ContentsSideMenuViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import UIKit

protocol ContentsSideMenuViewDelegate: AnyObject {
    func menuDidSelected(_ menu: ContentsSideMenuViewViewModel.Contents)
}

final class ContentsSideMenuViewController: BaseViewController {
    
    private var vm: ContentsSideMenuViewViewModel
    
    weak var delegate: ContentsSideMenuViewDelegate?
    
    //MARK: - UI Elements
    private let contentsTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: UITableViewCell.identifier)
        return table
    }()
    
    //MARK: - Init
    init(vm: ContentsSideMenuViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.updateTheme()
        
        self.baseDelegate = self
    }
    
    deinit {
        #if DEBUG
        print("Denit")
        #endif
    }
    
}

extension ContentsSideMenuViewController {
    private func setUI() {
        self.view.addSubviews(self.contentsTable)
    }
    
    private func setLayout() {
        self.contentsTable.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setDelegate() {
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
        switch theme {
        case .black:
            self.view.backgroundColor = .darkGray
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
