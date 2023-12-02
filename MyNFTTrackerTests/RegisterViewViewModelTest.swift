//
//  RegisterViewViewModelTest.swift
//  MyNFTTrackerTests
//
//  Created by HappyDuck on 12/1/23.
//

import XCTest
@testable import MyNFTTracker

final class RegisterViewViewModelTest: XCTestCase {
    // Given
    let walletAddress = "0x1234567890"
    var vm: RegisterViewViewModel?
    var vc: RegisterViewController?
    
    override func setUpWithError() throws {
        vm = RegisterViewViewModel(walletAddres: walletAddress)
        guard let vm = vm else { return }
        vc = RegisterViewController(vm: vm)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_ShouldSaveNickname() throws {
        
        guard let vm = vm else { return }
        
        // When
        vm.nickname = "HappyDuck"
        
        // Then
        XCTAssertEqual(vm.nickname, "HappyDuck")
    }
    
    func test_WalletAddressShouldBeSame() throws {
        guard let vm = vm else { return }
        
        // Then
        XCTAssertEqual(vm.walletAddres, walletAddress)
    }
    
    func test_ShouldCheckNicknameFilled() throws {
        guard let vc = vc,
              let vm = vm else { return }
        
        // When
        vc.vm.nickname = "HappyDuck"
        // Then
        XCTAssertTrue(vm.isNicknameFilled)
    }

}
