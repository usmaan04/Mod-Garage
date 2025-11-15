import XCTest
import Combine // We need this to listen to @Published properties
@testable import Mod_Garage

@MainActor
final class AuthIntegrationTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var logInVM: LoginViewModel!
    var cancellables: Set<AnyCancellable>! // Stores our Combine listeners

    override func setUp() {
        // This runs before each test
        signUpVM = SignUpViewModel()
        logInVM = LoginViewModel()
        cancellables = [] // Initialize an empty set
    }

    override func tearDown() {
        // This runs after each test
        cancellables = nil
        signUpVM = nil
        logInVM = nil
    }

    // MARK: - Sign Up Integration Tests

    func test_SignUp_FailsWithWeakPassword_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        // Create an "expectation". The test will wait until this is fulfilled.
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to avoid "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = uniqueEmail
        signUpVM.password = "123" // This is a weak password
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst() // Ignore the initial 'nil' value
            .sink { errorMessage in
                // 3. Assert
                // Check that the error message from Firebase is the one we expect
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test we're done waiting
                expectation.fulfill()
            }
            .store(in: &cancellables) // Store the listener

        // 2. Act
        // Call the function that makes the network request
        signUpVM.register()

        // Wait for the expectation to be fulfilled (or time out after 10 seconds)
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // MARK: - Login Integration Tests

    func test_Login_FailsWithInvalidEmailFormat_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return an invalid email error")
        
        logInVM.email = "this-is-not-an-email"
        logInVM.password = "any-password"

        // Set up a listener for the loginError property
        logInVM.$loginError
            .dropFirst() // Ignore the initial 'nil' value
            .sink { errorMessage in
                // 3. Assert
                // This is the specific error message you wrote in LoginViewModel's error handler
                let expectedError = "Invalid email or password. If you registered with Google, try the Google button below."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for an invalid email.")
                
                // Tell the test we're done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        logInVM.login()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func test_Login_FailsWithUserNotFound_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a user not found error")
        
        // Use a unique (and thus non-existent) email
        let nonExistentEmail = "user-does-not-exist-\(UUID().uuidString)@example.com"
        
        logInVM.email = nonExistentEmail
        logInVM.password = "any-password"

        // Set up a listener
        logInVM.$loginError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                // Your error handler groups these errors, so we expect the same message
                let expectedError = "Invalid email or password. If you registered with Google, try the Google button below."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a user not found error.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        logInVM.login()

        // Wait
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}

