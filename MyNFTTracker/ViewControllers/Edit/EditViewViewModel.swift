//
//  EditViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import Foundation
import UIKit.UIImage
import Combine

final class EditViewViewModel {
    var selectedAvatarIndex: IndexPath?
    
    @Published var profileImage: UIImage?
    @Published var showPickerView: Bool?
    @Published var canShowPickerView: Bool = true
    
}
