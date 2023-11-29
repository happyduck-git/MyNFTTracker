//
//  SnackbarViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/29/23.
//

import UIKit

typealias Handler = (() -> Void)

enum SnackbarViewType {
    case action(handler: Handler)
}

struct SnackbarViewViewModel {
    let type: SnackbarViewType
    let text: String
}
