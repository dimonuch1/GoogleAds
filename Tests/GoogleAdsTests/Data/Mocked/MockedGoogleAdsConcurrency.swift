//
//  MockedGoogleAdsConcurrency.swift
//  
//
//  Created by Koliush Dmitry on 18.02.2023.
//

@testable import GoogleAds
import GoogleMobileAds
import Combine

class MockedGoogleAdsConcurrency: GoogleAdsConcurrencyProtocol {

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
    public func configure() async {
        await configureGoogleAdsApp()
    }

    /// Configures the Google Ads App
    private func configureGoogleAdsApp() async {
        _ = await GADMobileAds.sharedInstance().start()
        self.isInitialized = true
    }

    // MARK: Interstitial Ads

    /// Loads an interstitial ad
    ///
    ///  - Throws: `GoogleAdsError.notInitialized`
    ///
    public func loadIntestitial() async throws {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let interstitialAdId = config.getInterstitialAdId()
        let ad = GADInterstitialAd()
        loadedInterstitials[interstitialAdId] = ad
    }

    /// Shows an interstitial ad
    ///
    /// - Parameters:
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - Returns: A `Bool` value of whether the display is successful or throw `Error`
    ///
    public func showInterstitial(fromRootViewController viewController: UIViewController) async throws -> Bool {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let interstitialAdId = config.getInterstitialAdId()

        guard let interstitial = loadedInterstitials[interstitialAdId] else {
            throw GoogleAdsError.interstitialNotLoaded
        }

        displayedAdId = .intersitial(id: interstitialAdId)
        interstitial.present(fromRootViewController: viewController)

        return true
    }

    // MARK: Rewarded Ads
    /// Loads a rewarded video ad
    ///
    ///  - Throws: `GoogleAdsError.notInitialized`
    ///
    ///
    public func loadRewardVideo() async throws {

        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()
        let resultAd = GADRewardedAd()
        loadedRewardedVideos[rewardedVideoAdId] = resultAd
    }

    /// Shows a rewarded ad
    ///
    /// - parameters:
    ///     - viewController: A view controller to present the ad
    ///
    ///  - returns: `AdReward` or an throw error
    ///
    ///  - Throws: `GoogleAdsError.rewardedVideoNotLoaded`, `GoogleAdsError.notInitialized`
    ///
    public func showRewardVideo(fromRootViewController viewController: UIViewController) async throws -> AdReward {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        guard loadedRewardedVideos[rewardedVideoAdId] != nil else {
            throw GoogleAdsError.rewardedVideoNotLoaded
        }

        displayedAdId = .rewardedVideo(id: rewardedVideoAdId)

        return await withCheckedContinuation({ (continuation: CheckedContinuation<AdReward, Never>) in
            let adReward = AdReward(amount: 10, type: "test")
            continuation.resume(returning: adReward)
        })
    }

}
