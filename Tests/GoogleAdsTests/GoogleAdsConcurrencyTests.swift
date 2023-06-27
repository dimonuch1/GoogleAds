import XCTest
@testable import GoogleAds
import GoogleMobileAds

final class GoogleAdsConcurrencyTests: XCTestCase {

    var config = GoogleAdsConfig(interstitial: "interstitialAdId",
                                 rewardVideo: "",
                                 defaultInterstitialAdId: "",
                                 defaultRewardedVideoAdId: "")

    var googleAds: MockedGoogleAdsConcurrency!

    override func setUp() {
        super.setUp()
        googleAds = MockedGoogleAdsConcurrency(config: config)
    }

    func testGoogleAdsInitializationStateAfterInit() {
        XCTAssertFalse(googleAds.isInitialized)
    }

    func testConfigAsyncInitializedIsTrue() async {
        await googleAds.configure()
        XCTAssertTrue(googleAds.isInitialized)
    }
}

// MARK: - Interstitial
extension GoogleAdsConcurrencyTests {
    func testThrowErrorWhenPresentIfNotConfigured() async throws {
        let controller = await UIViewController()
        do {
            _ = try await googleAds.showInterstitial(fromRootViewController: controller)
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, GoogleAdsError.notInitialised)
        }
    }

    func testThrowErrorWhenPresentIfNotLoaded() async throws {
        let controller = await UIViewController()
        await googleAds.configure()
        do {
            _ = try await googleAds.showInterstitial(fromRootViewController: controller)
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, GoogleAdsError.interstitialNotLoaded)
        }
    }

    func testDisplayedAdIdAfterPresentInterstitial() async throws {
        let controller = await UIViewController()
        await googleAds.configure()

        // inimatet loading interstitial
        let interstitialAdId = config.getInterstitialAdId()
        googleAds.loadedInterstitials[interstitialAdId] = GADInterstitialAd()
        do {
            _ = try await googleAds.showInterstitial(fromRootViewController: controller)
            let intersitialDisplayAdType = MockedGoogleAdsConcurrency.DisplayedAdType.intersitial(id: config.interstitial)
            XCTAssertEqual(intersitialDisplayAdType, googleAds.displayedAdId)
        } catch {
            XCTFail()
        }
    }

    func testReturnTrueAfterPresentInterstitial() async throws {
        let controller = await UIViewController()
        await googleAds.configure()

        // inimatet loading interstitial
        let interstitialAdId = config.getInterstitialAdId()
        googleAds.loadedInterstitials[interstitialAdId] = GADInterstitialAd()
        do {
            let result = try await googleAds.showInterstitial(fromRootViewController: controller)
            XCTAssert(result)
        } catch {
            XCTFail()
        }
    }

    func testLoadIntestitialThrowInitialError() async throws {
        let expected = GoogleAdsError.notInitialised
        do {
            _ = try await googleAds.loadIntestitial()
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, expected)
        }
    }

    func testLoadIntestitial() async throws {
        let expectedLoadedIntestitialAmaunt = 1
        await googleAds.configure()
        do {
            XCTAssert(googleAds.loadedInterstitials .isEmpty)
            try await googleAds.loadIntestitial()
            XCTAssertEqual(expectedLoadedIntestitialAmaunt, googleAds.loadedInterstitials.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

// MARK: - Reward Video
extension GoogleAdsConcurrencyTests {
    func testLoadRewardedVideoThrowInitialError() async throws {
        let expected = GoogleAdsError.notInitialised
        do {
            _ = try await googleAds.loadRewardVideo()
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, expected)
        }
    }

    func testLoadRewardedVideo() async throws {
        let expectedLoadedVideoAmaunt = 1
        await googleAds.configure()
        do {
            XCTAssert(googleAds.loadedRewardedVideos.isEmpty)
            try await googleAds.loadRewardVideo()
            XCTAssertEqual(expectedLoadedVideoAmaunt, googleAds.loadedRewardedVideos.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testshowRewardVideo() async throws {
        let controller = await UIViewController()
        let expectetion = AdReward(amount: 10, type: "test")

        // check throw notInitialized error
        do {
            try await googleAds.loadRewardVideo()
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, .notInitialised)
            await googleAds.configure()
        }

        // check throw rewardedVideoNotLoaded error
        do {
            _ = try await googleAds.showRewardVideo(fromRootViewController: controller)
            XCTFail("Reward can't be show is reward dosen't loaded")
        } catch let error as GoogleAdsError {
            XCTAssertEqual(error, .rewardedVideoNotLoaded)
        }

        try await googleAds.loadRewardVideo()

        do {
            let result = try await googleAds.showRewardVideo(fromRootViewController: controller)
            XCTAssertEqual(expectetion, result)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
