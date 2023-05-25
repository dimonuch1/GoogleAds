//
//  GoogleAdsCombineTest.swift
//  
//
//  Created by Koliush Dmitry on 14.02.2023.
//

import XCTest
@testable import GoogleAds
import GoogleMobileAds
import Combine

final class GoogleAdsCombineTest: XCTestCase {

    var config = GoogleAdsConfig(interstitial: "interstitialAdId",
                                 rewardVideo: "",
                                 defaultInterstitialAdId: "",
                                 defaultRewardedVideoAdId: "")

    var googleAds: MockedGoogleAdsCombine!

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        googleAds = MockedGoogleAdsCombine(config: config)
        cancellables = []
    }

    func testGoogleAdsInitializationStateAfterInit() {
        XCTAssertFalse(googleAds.isInitialized)
    }

    func testConfigAsyncInitializedIsTrue() {

        let expected = true
        let publisher = googleAds.configure()
        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
    }
}

// MARK: - Interstitial
extension GoogleAdsCombineTest {
    func testThrowErrorWhenPresentIfNotConfigured() {
        let controller = UIViewController()
        let expected: GoogleAdsError = .notInitialized
        let publisher = googleAds.showInterstitial(fromRootViewController: controller)
        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
    }

    func testThrowErrorWhenPresentIfNotLoaded() throws {
        let controller = UIViewController()
        let expected: GoogleAdsError = .interstitialNotLoaded

        _ = try awaitPublisher(googleAds.configure())

        let publisher = googleAds.showInterstitial(fromRootViewController: controller)
        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
    }

    func testDisplayedAdIdAfterPresentInterstitial() throws {
        let controller =  UIViewController()
        let expected: MockedGoogleAdsCombine.DisplayedAdType = .intersitial(id: config.interstitial)

        _ = try awaitPublisher(googleAds.configure())

        // inimatet loading interstitial
        let interstitialAdId = config.getInterstitialAdId()
        googleAds.loadedInterstitials[interstitialAdId] = GADInterstitialAd()

        _ = try awaitPublisher(googleAds.showInterstitial(fromRootViewController: controller))
        XCTAssertEqual(expected, googleAds.displayedAdId)
    }

    func testReturnTrueAfterPresentInterstitial() throws {
        let controller = UIViewController()
        let expected = true

        _ = try awaitPublisher(googleAds.configure())

        // inimatet loading interstitial
        let interstitialAdId = config.getInterstitialAdId()
        googleAds.loadedInterstitials[interstitialAdId] = GADInterstitialAd()
        let publisher = googleAds.showInterstitial(fromRootViewController: controller)

        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
    }

    func testLoadInterstitialIfNotInitialized() {
        let publisher = googleAds.loadIntestitial()
        let expected: GoogleAdsError = .notInitialized

        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
    }

    func testLoadInterstitialAfetrConfig() throws {
        _ = try? awaitPublisher(googleAds.configure())

        XCTAssert(googleAds.loadedInterstitials.isEmpty)
        let publisher = googleAds.loadIntestitial()
        let expected = true
        let result = isPublishersResultSameAsExpected(publisher, expected: expected)
        XCTAssertTrue(result)
        XCTAssert(!googleAds.loadedInterstitials.isEmpty)
    }
}

// MARK: - Reward Video
extension GoogleAdsCombineTest {
    func test_load_reward_video_with_test_no_initial_error() {

        // check throw notInitialized error if not configured
        let publisher = googleAds.loadRewardVideo()
        let expectedInitialError = GoogleAdsError.notInitialized
        let result = isPublishersResultSameAsExpected(publisher,
                                                      expected: expectedInitialError)
        XCTAssertTrue(result)

        // configure
        let success = try? awaitPublisher(googleAds.configure())
        XCTAssert(success == true)

        // check result after configur
        let publisher1 = googleAds.loadRewardVideo()
        let expected = true
        let result1 = isPublishersResultSameAsExpected(publisher1,
                                                       expected: expected)
        XCTAssertTrue(result1)
    }

    func test_show_reward_video() {
        let controller = UIViewController()
        let expectetion = AdReward(amount: 10, type: "test")

        // check throw notInitialized error
        let publisher = googleAds.loadRewardVideo()
        let expectedInitialError = GoogleAdsError.notInitialized
        let result = isPublishersResultSameAsExpected(publisher,
                                                      expected: expectedInitialError)
        XCTAssert(result)
        let success = try? awaitPublisher(googleAds.configure())
        XCTAssert(success == true)

        let publisherShowRewardError = googleAds.showRewardVideo(fromRootViewController: controller)
        let expectedShowError = GoogleAdsError.rewardedVideoNotLoaded
        let resultErrorShow = isPublishersResultSameAsExpected(publisherShowRewardError,
                                                               expected: expectedShowError)
        XCTAssert(resultErrorShow)

        // load reward video
        let loadSuccess = try? awaitPublisher(googleAds.loadRewardVideo())
        XCTAssert(loadSuccess == true)

        // show reward video
        let showRewardPublisher = googleAds.showRewardVideo(fromRootViewController: controller)
        let resultShowReward = isPublishersResultSameAsExpected(showRewardPublisher,
                                                      expected: expectetion)
        XCTAssert(resultShowReward)
    }
}


// MARK: - Extensions -
extension XCTestCase {

    func isPublishersResultSameAsExpected<T: Publisher, A: Equatable>(_ publisher: T,
                                                            timeout: TimeInterval = 10,
                                                            expected: A) -> Bool {
        let result: Result<T.Output, Error>? = awaitResult(publisher, timeout: timeout)
        switch result {
        case .failure(let error):
            if let expecteError = error as? A {
                return expected == expecteError
            }
        case .success(let value):
            if let expectedValue = value as? A {
                return expected == expectedValue
            }
        case .none:
            return false
        }
        return false
    }

    func awaitResult<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Result<T.Output, Error>? {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        return result
    }

    func awaitPublisher<T: Publisher>(
            _ publisher: T,
            timeout: TimeInterval = 10,
            file: StaticString = #file,
            line: UInt = #line
        ) throws -> T.Output {
            // This time, we use Swift's Result type to keep track
            // of the result of our Combine pipeline:
            var result: Result<T.Output, Error>?
            let expectation = self.expectation(description: "Awaiting publisher")

            let cancellable = publisher.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        result = .failure(error)
                    case .finished:
                        break
                    }

                    expectation.fulfill()
                },
                receiveValue: { value in
                    result = .success(value)
                }
            )

            // Just like before, we await the expectation that we
            // created at the top of our test, and once done, we
            // also cancel our cancellable to avoid getting any
            // unused variable warnings:
            waitForExpectations(timeout: timeout)
            cancellable.cancel()

            // Here we pass the original file and line number that
            // our utility was called at, to tell XCTest to report
            // any encountered errors at that original call site:
            let unwrappedResult = try XCTUnwrap(
                result,
                "Awaited publisher did not produce any output",
                file: file,
                line: line
            )

            return try unwrappedResult.get()
        }
}
