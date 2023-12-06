//
//  EditViewViewModelTest.swift
//  MyNFTTrackerTests
//
//  Created by HappyDuck on 12/5/23.
//

import XCTest
import Combine
@testable import MyNFTTracker

final class EditViewViewModelTest: XCTestCase {

    var editViewModel: EditViewViewModel?
    var bindings = Set<AnyCancellable>()
    override func setUpWithError() throws {
        let mockUser = User(id: UUID().uuidString,
                            address: "0x000000",
                            nickname: "mock-user",
                            imageData: "abcd.png")
        editViewModel = EditViewViewModel(userInfo: mockUser)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_infoChanged_ShouldAssertTrue() {
        
        var result: Bool = false
        editViewModel!.infoChanged.sink { val in
            result = val
        }
        .store(in: &bindings)
 
        editViewModel!.isNicknameChanged = true
        editViewModel!.isProfileChanged = false

        XCTAssertTrue(result)
    }
    

}
