import XCTest
@testable import life_adapt_ios

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ViewController()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testUploadDataToAmplify() {
        // Create XCTestExpectation to wait for async task completion
        let expectation = self.expectation(description: "Data uploaded successfully")
        viewController.uploadDataToAmplify()
        // Wait for some time to allow the asynchronous task to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        // Wait for the expectation to be fulfilled with a timeout
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Timeout waiting for expectation: \(error)")
            }
            // accelerometerDataX, accelerometerDataY, and accelerometerDataZ are empty after upload
            XCTAssertTrue(self.viewController.accelerometerDataX.isEmpty)
            XCTAssertTrue(self.viewController.accelerometerDataY.isEmpty)
            XCTAssertTrue(self.viewController.accelerometerDataZ.isEmpty)
        }
    }
}
