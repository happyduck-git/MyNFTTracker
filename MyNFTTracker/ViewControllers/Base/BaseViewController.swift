//
//  BaseViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import SnapKit

protocol BaseViewControllerDelegate: AnyObject {
    func firstBtnTapped()
    func secondBtnTapped()
}

class BaseViewController: UIViewController {

    weak var baseDelegate: BaseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


}

// MARK: - Alert Controller
extension BaseViewController {
    func showAlert(alertTitle: String?,
                   alertMessage: String?,
                   alertStyle: UIAlertController.Style,
                   actionTitle1: String?,
                   actionStyle1: UIAlertAction.Style,
                   actionTitle2: String? = nil,
                   actionStyle2: UIAlertAction.Style? = nil
    ) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: alertStyle
        )
        
        if let title2 = actionTitle2,
           let action2 = actionStyle2 {
            let action2 = UIAlertAction(
                title: title2,
                style: action2
            ) { [weak self] _ in
                guard let `self` = self else { return }
                
                self.baseDelegate?.secondBtnTapped()
            }
            
            alert.addAction(action2)
        }

        let action1 = UIAlertAction(
            title: actionTitle1,
            style: actionStyle1
        ) { [weak self] _ in
            guard let `self` = self else { return }
            
            self.baseDelegate?.firstBtnTapped()
        }
        
        alert.addAction(action1)
        
        self.present(alert, animated: true)
    }
}
