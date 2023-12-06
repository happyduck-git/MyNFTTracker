//
//  ToggleCell.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/22/23.
//

import UIKit
import SnapKit
import Combine

protocol ToggleCellDelegate: AnyObject {
    func didToggle(_ isOn: Bool)
}

final class ToggleCell: UITableViewCell {
    
    weak var delegate: ToggleCellDelegate?
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleButton: UISwitch = {
       let toggler = UISwitch()
        toggler.translatesAutoresizingMaskIntoConstraints = false
        return toggler
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ToggleCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleLabel,
                                     self.toggleButton)
    }
    
    private func setLayout() {
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.toggleButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension ToggleCell {
    func configure(text: String, isOn: Bool) {
        self.titleLabel.text = text
        self.toggleButton.isOn = isOn
        
        self.overrideUserInterfaceStyle = isOn ? .light : .dark
    }
    
    func bind() {
        self.toggleButton.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.delegate?.didToggle($0)
            }
            .store(in: &self.bindings)
    }
}
