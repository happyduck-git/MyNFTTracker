//
//  SceneDelegate.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import FirebaseCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        FirebaseApp.configure()
        
        var vc: BaseViewController?
        
        if let address = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) {
            print("Saved address: \(address)")
            let vm = MainViewViewModel()
            vc = MainViewController(vm: vm)
            
        } else {
            let vm = LoginViewViewModel()
            vc = LoginViewController(vm: vm)
        }
        
//        let registerVM = RegisterViewViewModel(walletAddres: "0x00000000000")
//        let vc = RegisterViewController(vm: registerVM)
        
//        vc = WelcomeViewController(vm: WelcomeViewViewmodel(address: "0xf9C6e0F084c03e54a1E744e42B47C338A5FFc34D"))
        
        
        window?.rootViewController = UINavigationController(rootViewController: vc ?? BaseViewController())
        window?.makeKeyAndVisible()
        print(#function)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.walletAddress)
        MetamaskManager.shared.metaMaskSDK.clearSession()
        print(#function)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print(#function)
        // 이 부분 호출되었는데 address 받은 것 없으면 error handling하기.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print(#function)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print(#function)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print(#function)
    }


}

