//
//  MainViewViewModelTest.swift
//  MyNFTTrackerTests
//
//  Created by HappyDuck on 12/25/23.
//

import XCTest
@testable import MyNFTTracker

final class MainViewViewModelTest: XCTestCase {
    
    var mainViewModel: MainViewViewModel?
    
    override func setUpWithError() throws {
        mainViewModel = MainViewViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_buildPinataUrl_shouldAssertTrue() throws {
        guard let vm = mainViewModel else { return }
        let originalUrlString = "ipfs://test.png"
        let convertedUrlString = "https://gateway.pinata.cloud/ipfs/test.png"
        
        var isSame = vm.buildPinataUrl(from: originalUrlString) == convertedUrlString ? true : false
        XCTAssertTrue(isSame)
    }

}
