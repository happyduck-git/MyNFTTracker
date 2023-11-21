//
//  ToggleCell.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/22/23.
//

import UIKit
import SnapKit

protocol ToggleCellDelegate: AnyObject {
    func didToggle()
}

final class ToggleCell: UITableViewCell {
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
    
    
}

extension ToggleCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleLabel,
                                     self.toggleButton)
    }
    
    private func setLayout() {
        
    }
}
