//
//  AvatarCollectionViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import UIKit
import SnapKit
import Combine

protocol AvatarCollectionViewControllerDelegate: AnyObject {
    func avatarCollectionViewController(_ avatarCollectionViewController: AvatarCollectionViewController,
                                        didSelectAvatar avatar: UIImage?,
                                        at indexPath: IndexPath)
}

final class AvatarCollectionViewController: UIViewController {
    
    private let vm: AvatarCollectionViewViewModel
    private var bindings = Set<AnyCancellable>()
    
    unowned var delegate: AvatarCollectionViewControllerDelegate
    
    //MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = AvatarConstants.title
        label.textColor = AppColors.DarkMode.text
        label.font = .appFont(name: .appMainFontBold, size: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(AvatarCollectionViewCell.self, forCellWithReuseIdentifier: AvatarCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .darkGray.withAlphaComponent(0.8)
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.bind()
    }
    //MARK: - Init
    
    init(vm: AvatarCollectionViewViewModel,
         delegate: AvatarCollectionViewControllerDelegate
    ) {
        self.vm = vm
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AvatarCollectionViewController {
    private func setUI() {
        self.view.addSubviews(self.titleLabel,
                              self.collectionView)
    }
    
    private func setLayout() {
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
        }
        
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
    }
    
    private func setDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func bind() {
        self.vm.$avatarImages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageList in
                guard let `self` = self else { return }
 
                self.vm.cellStatus = Array(repeating: false, count: imageList.count)
                self.collectionView.reloadData()
                
            }
            .store(in: &bindings)
    }
}

extension AvatarCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.vm.avatarImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCollectionViewCell.identifier, for: indexPath) as? AvatarCollectionViewCell else {
            return UICollectionViewCell()
        }
 
        if !self.vm.cellStatus.isEmpty {
            if let selectedItem = self.vm.selectedCell?.item {
                self.vm.cellStatus[selectedItem] = true
            }
           
            cell.configure(image: self.vm.avatarImages[indexPath.item], checkHidden: self.vm.cellStatus[indexPath.item])
            return cell
        }
        
        cell.configure(image: self.vm.avatarImages[indexPath.item], checkHidden: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width - 30) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = self.vm.selectedCell?.item {
            let prev = selectedCell
            self.vm.cellStatus[prev] = false
            guard let prevCell = collectionView.cellForItem(at: IndexPath(item: prev, section: 0)) as? AvatarCollectionViewCell else { return }
            prevCell.showCheckmark(false)
        }
            self.vm.selectedCell = indexPath
            self.vm.cellStatus[indexPath.item] = true
            guard let cell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell else { return }
            cell.showCheckmark(true)
            self.delegate.avatarCollectionViewController(self,
                                                         didSelectAvatar: self.vm.avatarImages[indexPath.item],
                                                         at: indexPath)
    }
}
