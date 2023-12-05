//
//  BaseViewController.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import UIKit
import SnapKit

protocol BaseViewControllerDelegate: AnyObject {  
    func themeChanged(as theme: Theme)
    func userInfoChanged(as user: User)
}

class BaseViewController: UIViewController {

    weak var baseDelegate: BaseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupThemeNotification()
        self.setupInfoChangeNotification()
    }


}

extension BaseViewController {
    private func setupThemeNotification() {
        NotificationCenter.default.addObserver(forName: Notification.Name(NotificationConstants.theme),
                                               object: nil,
                                               queue: nil) { [weak self] noti in
            guard let `self` = self,
                  let theme = noti.object as? Theme
            else { return }
            
            self.baseDelegate?.themeChanged(as: theme)
            print("Obj recieved: \(theme)")
        }
    }
    
    private func setupInfoChangeNotification() {
        NotificationCenter.default.addObserver(forName: Notification.Name(NotificationConstants.userInfo),
                                               object: nil,
                                               queue: nil) { noti in
            guard let user = noti.object as? User else { return }
            self.baseDelegate?.userInfoChanged(as: user)
            AppLogger.logger.info("UserInfo change notified -- detail: \(String(describing: user))")
        }
    }
}

