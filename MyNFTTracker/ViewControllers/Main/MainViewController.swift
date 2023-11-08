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

final class MainViewController: UIViewController {
    
    private let vm: MainViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemRed
        collection.register(NFTCardCell.self, forCellWithReuseIdentifier: NFTCardCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
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
        
        view.backgroundColor = .systemYellow
        
        self.nftCollectionView.delegate = self
        self.nftCollectionView.dataSource = self
        
        self.bind()
        self.setUI()
        self.setLayout()
    }
    
}

extension MainViewController {
    
    private func bind() {
        self.vm.$nfts
            .sink { [weak self] nfts in
                guard let `self` = self else { return }
                
                self.vm.imageStrings = nfts.compactMap { $0.metadata?.image }
                
                DispatchQueue.main.async {
                    self.nftCollectionView.reloadData()
                }
                
            }
            .store(in: &bindings)
    }
    
}

extension MainViewController {
    
    private func setUI() {
        self.view.addSubviews(self.nftCollectionView)
    }
    
    private func setLayout() {
        self.nftCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalTo(self.view.snp.leading).offset(20)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-20)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.height.equalTo(300)
        }
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
        
        if let url = URL(string: self.vm.imageStrings[indexPath.item]) {
            Task {
                do {
                    let image = try await ImagePipeline.shared.image(for: url)
                    
                    DispatchQueue.main.async {
                        cell.configureImage(image: image)
                    }
                }
                catch {
                    print("Error fetching image -- \(error.localizedDescription)")
                }
                
            }
            return cell
        }
        cell.configureImage(image: UIImage(resource: .myNFTTrackerLogo))
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 1.5
        return CGSize(width: width, height: width)
    }
    
}
