//
//  MockedGoogleAdsCombine.swift
//  
//
//  Created by Koliush Dmitry on 18.02.2023.
//

@testable import GoogleAds
import GoogleMobileAds
import Combine

class MockedGoogleAdsCombine: GoogleAdsCombinePresenter {

    private var fullScreenAdsPresented = PassthroughSubject<Bool, Error>()
    /// A publisher of whether an ad is presented fullscreen
    public lazy var fullScreenAdsPresentedPublisher: AnyPublisher<Bool, Error> =
        fullScreenAdsPresented.eraseToAnyPublisher()

    var loadedInterstitials = [String: GADInterstitialAd]()
    var loadedRewardedVideos = [String: GADRewardedAd]()

    var isInitialized = false
    let config: GoogleAdsConfig
    var displayedAdId: DisplayedAdType?

    public init(config: GoogleAdsConfig) {
        self.config = config
    }

    enum DisplayedAdType: Equatable {
        case intersitial(id: String)
        case rewardedVideo(id: String)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.intersitial(let lhsValue), .intersitial(let rhsValue)),
                (.rewardedVideo(let lhsValue), .rewardedVideo(let rhsValue)):
                return lhsValue == rhsValue
            default: return false
            }
        }

    }

    // MARK: Configure

    /// Configures the Google Ads App
    ///
    ///  - returns: A publisher of whether the start is successful or an error
    ///
    public func configure() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            GADMobileAds.sharedInstance().start { [weak self] _ in
                self?.isInitialized = true
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: Interstitial Ads

    /// Loads an interstitial ad
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    public func loadIntestitial() -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        let interstitialAdId = config.getInterstitialAdId()

        return Future<Bool, Error> { promise in
            let testAd = GADInterstitialAd()
            self.loadedInterstitials[interstitialAdId] = testAd
            promise(.success(true))
        }
        .eraseToAnyPublisher()
    }

    /// Shows an interstitial ad
    ///
    /// - Parameters:
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - Returns: A publisher of whether the display is successful or an error
    ///
    public func showInterstitial(fromRootViewController viewController: UIViewController) -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        let interstitialAdId = config.getInterstitialAdId()

        guard let interstitial = loadedInterstitials[interstitialAdId] else {
            return Fail(error: GoogleAdsError.interstitialNotLoaded).eraseToAnyPublisher()
        }

        displayedAdId = .intersitial(id: interstitialAdId)
        interstitial.present(fromRootViewController: viewController)

        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // MARK: Rewarded Ads
    /// Loads a rewarded video ad
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    public func loadRewardVideo() -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        return Future<Bool, Error> { promise in
            let ad = GADRewardedAd()
            self.loadedRewardedVideos[rewardedVideoAdId] = ad
            promise(.success(true))
        }.eraseToAnyPublisher()
    }

    // Shows a rewarded ad
    ///
    /// - parameters:
    ///     - viewController: A view controller to present the ad
    ///
    ///  - returns: A publisher of the `AdReward` or an error
    ///
    public func showRewardVideo(fromRootViewController viewController: UIViewController) -> AnyPublisher<AdReward, Error> {
        guard isInitialized else {
            return Fail<AdReward, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        guard loadedRewardedVideos[rewardedVideoAdId] != nil else {
            return Fail(error: GoogleAdsError.rewardedVideoNotLoaded).eraseToAnyPublisher()
        }

        displayedAdId = .rewardedVideo(id: rewardedVideoAdId)

        return Future<AdReward, Error> { promise in
            let expectetion = AdReward(amount: 10, type: "test")
            promise(.success(expectetion))
        }.eraseToAnyPublisher()
    }

}
