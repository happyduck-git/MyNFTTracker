//
//  EditViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import UIKit

final class EditViewController: BaseViewController {
    
    private let vm: EditViewViewModel
    
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
        textField.font = .appFont(name: .appMainFontMedium, size: .plain)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: - Init
    init(vm: EditViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EditViewController: AvatarCollectionViewControllerDelegate, UISheetPresentationControllerDelegate {
    private func showAvatarPicker() {
        let vm = AvatarCollectionViewViewModel(selectedCell: self.vm.selectedAvatarIndex)
        let viewControllerToPresent = AvatarCollectionViewController(vm: vm, delegate: self)
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.delegate = self
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    func avatarCollectionViewController(_ avatarCollectionViewController: AvatarCollectionViewController, didSelectAvatar avatar: UIImage?, at indexPath: IndexPath) {
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.vm.showPickerView = false
        self.vm.canShowPickerView = true
    }
}
