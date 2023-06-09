//
//  GoogleAds.swift
//
//
//  Created by Koliush Dmitry on 23.07.2022.
//

import AppTrackingTransparency
import GoogleMobileAds
import Combine

///  Class provide you show google ads in swiftui view
public class GoogleAds: NSObject {
//    private var fullScreenAdsPresented = PassthroughSubject<Bool, Error>()
//    /// A publisher of whether an ad is presented fullscreen
//    private lazy var fullScreenAdsPresentedPublisher: AnyPublisher<Bool, Error> =
//        fullScreenAdsPresented.eraseToAnyPublisher()

    private var loadedInterstitials = [String: GADInterstitialAd]()
    private var loadedRewardedVideos = [String: GADRewardedAd]()

    private var isInitialized = false
    private let config: GoogleAdsConfig
    private var displayedAdId: DisplayedAdType?

    public weak var adsFullScreenContentDelegate: ADSFullScreenContentDelegate?

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
}

// MARK: - Combine Style -
extension GoogleAds: GoogleAdsCombinePresenter {





    /// Requests tracking authorization to deliver personalised ads
    ///
    ///  - returns: A publisher of whether the access is granted
    ///
    public func requestTrackingAuthorization() -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { promise in
            let status = ATTrackingManager.trackingAuthorizationStatus

            guard status == .notDetermined else {
                promise(.success(status == .authorized))
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Fix for iOS 15
                ATTrackingManager.requestTrackingAuthorization {
                    promise(.success($0 == .authorized))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: Configure

    public func configure() -> AnyPublisher<Bool, Error> {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = config.testDeviceIdentifiers
        return Future<Bool, Error> { promise in
            GADMobileAds.sharedInstance().start { [weak self] _ in
                self?.isInitialized = true
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }

    // MARK: Interstitial Ads

    public func loadIntestitial() -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialized).eraseToAnyPublisher()
        }

        let interstitialAdId = config.getInterstitialAdId()

        guard loadedInterstitials[interstitialAdId] == nil else {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let request = GADRequest()

        return Future<Bool, Error> { promise in
            GADInterstitialAd.load(withAdUnitID: interstitialAdId,
                                   request: request) { [weak self] ad, error in
                guard let ad = ad else {
                    promise(.failure(error ?? GoogleAdsError.rewardedVideoLoadingFailed))
                    return
                }

                ad.fullScreenContentDelegate = self
                self?.loadedInterstitials[interstitialAdId] = ad

                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }

    public func showInterstitial(fromRootViewController viewController: UIViewController) -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialized).eraseToAnyPublisher()
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
    public func loadRewardVideo() -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialized)
                .eraseToAnyPublisher()
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        guard loadedRewardedVideos[rewardedVideoAdId] == nil else {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let request = GADRequest()

        return Future<Bool, Error> { promise in
            GADRewardedAd.load(withAdUnitID: rewardedVideoAdId,
                               request: request) { [weak self] ad, error in
                guard let self else { return }
                guard let ad = ad else {
                        promise(.failure(GoogleAdsError.rewardedVideoLoadingFailed))
                    return
                }
//                promise(.failure(GoogleAdsError.rewardedVideoLoadingFailed))
//                return
                ad.fullScreenContentDelegate = self
                self.loadedRewardedVideos[rewardedVideoAdId] = ad

                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }

    public func showRewardVideo(fromRootViewController viewController: UIViewController) -> AnyPublisher<AdReward, Error> {
        guard isInitialized else {
            return Fail<AdReward, Error>(error: GoogleAdsError.notInitialized).eraseToAnyPublisher()
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        guard let rewardedVideo = loadedRewardedVideos[rewardedVideoAdId] else {
            return Fail(error: GoogleAdsError.rewardedVideoNotLoaded).eraseToAnyPublisher()
        }

        displayedAdId = .rewardedVideo(id: rewardedVideoAdId)

        return Future<AdReward, Error> { promise in

            rewardedVideo.present(fromRootViewController: viewController) {
                let reward = rewardedVideo.adReward

                let adReward = AdReward(amount: reward.amount.intValue, type: reward.type)

                promise(.success(adReward))
            }
        }
        .eraseToAnyPublisher()
    }
}


// MARK: - Concurrency Style -
extension GoogleAds: GoogleAdsConcurrencyProtocol {

    
    // MARK: Configure

    /// Configures the Google Ads App
    public func configure() async {
        await configureGoogleAdsApp()
    }

    /// Configures the Google Ads App
    private func configureGoogleAdsApp() async {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = config.testDeviceIdentifiers
        _ = await GADMobileAds.sharedInstance().start()
        self.isInitialized = true
    }

    // MARK: Interstitial Ads

    /// Loads an interstitial ad
    ///
    ///  - Throws: `GoogleAdsError.interstitialLoadingFailed`, `GoogleAdsError.notInitialized`
    ///
    public func loadIntestitial() async throws {
        guard isInitialized else {
            throw GoogleAdsError.notInitialized
        }

        let interstitialAdId = config.getInterstitialAdId()
        let request = GADRequest()

        do {
            let ad = try await GADInterstitialAd.load(withAdUnitID: interstitialAdId,
                                                      request: request)
            ad.fullScreenContentDelegate = self
            loadedInterstitials[interstitialAdId] = ad
        } catch {
            throw GoogleAdsError.interstitialLoadingFailed
        }
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
            throw GoogleAdsError.notInitialized
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
    ///  - Throws: `GoogleAdsError.rewardedVideoLoadingFailed`, `GoogleAdsError.notInitialized`
    ///
    ///
    public func loadRewardVideo() async throws {

        guard isInitialized else {
            throw GoogleAdsError.notInitialized
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()
        let request = GADRequest()
        do {
            let ad = try await GADRewardedAd.load(withAdUnitID: rewardedVideoAdId, request: request)
            ad.fullScreenContentDelegate = self
            loadedRewardedVideos[rewardedVideoAdId] = ad
        } catch {
            throw GoogleAdsError.rewardedVideoLoadingFailed
        }
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
            throw GoogleAdsError.notInitialized
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

        guard let rewardedVideo = loadedRewardedVideos[rewardedVideoAdId] else {
            throw GoogleAdsError.rewardedVideoNotLoaded
        }

        displayedAdId = .rewardedVideo(id: rewardedVideoAdId)

        return await withCheckedContinuation({ (continuation: CheckedContinuation<AdReward, Never>) in
            rewardedVideo.present(fromRootViewController: viewController) {
                let reward = rewardedVideo.adReward
                let adReward = AdReward(amount: reward.amount.intValue, type: reward.type)
                continuation.resume(returning: adReward)
            }
        })
    }
}

// MARK: - GADFullScreenContentDelegate -
extension GoogleAds: GADFullScreenContentDelegate {
    public func ad(_ ad: GADFullScreenPresentingAd,
                   didFailToPresentFullScreenContentWithError error: Error) {
        adsFullScreenContentDelegate?.ad(ad, didFailToPresentFullScreenContentWithError: error)
//        fullScreenAdsPresented.send(completion: .failure(error))
    }

    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adWillPresentFullScreenContent(ad)
        removeDisplayedAd()

//        fullScreenAdsPresented.send(true)
    }

    private func removeDisplayedAd() {
        guard let displayedAdId = displayedAdId else { return }

        switch displayedAdId {
        case .intersitial(let id):
            _ = loadedInterstitials.removeValue(forKey: id)

        case .rewardedVideo(let id):
            _ = loadedRewardedVideos.removeValue(forKey: id)
        }

        self.displayedAdId = nil
    }

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidDismissFullScreenContent(ad)
//        fullScreenAdsPresented.send(false)
    }

    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adWillDismissFullScreenContent(ad)
    }

    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidRecordClick(ad)
    }

    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidRecordImpression(ad)
    }
}
