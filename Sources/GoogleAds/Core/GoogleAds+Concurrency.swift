//
//  GoogleAds+GoogleAdsConcurrencyProtocol.swift
//  
//
//  Created by Koliush Dmytro on 09.06.2023.
//

import AppTrackingTransparency
import GoogleMobileAds

// MARK: - Concurrency Style -
extension GoogleAds: GoogleAdsConcurrencyProtocol {

    // MARK: - Configure -

    /// Configures the Google Ads App
    public func configure() async {
        await configureGoogleAdsApp()
    }

    @MainActor
    @discardableResult
    public func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        await withCheckedContinuation { continuation in
            // Bug from iOS 15. Needed some delay before request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    continuation.resume(with: .success(status))
                }
            }
        }
    }

    /// Configures the Google Ads App
    private func configureGoogleAdsApp() async {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = config.testDeviceIdentifiers
        _ = await GADMobileAds.sharedInstance().start()
        isInitialized = true
    }

    // MARK: - Interstitial -

    /// Loads an interstitial ad
    ///
    ///  - Throws: `GoogleAdsError.interstitialLoadingFailed`, `GoogleAdsError.notInitialised`
    ///
    public func loadInterstitial<T: Hashable>(_ type: T) async throws where T: Equatable {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let interstitialAdId = try config.getInterstitialAdId(type)
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
    ///  - Returns: A `Bool` value of whether the display is successful or throws `Error`
    ///
    @MainActor
    @discardableResult
    public func showInterstitial<T: Hashable>(
        _ type: T,
        fromRootViewController viewController: UIViewController) async throws -> Bool
    {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let interstitialAdId = try config.getInterstitialAdId(type)

        guard let interstitial = loadedInterstitials[interstitialAdId] else {
            throw GoogleAdsError.interstitialNotLoaded
        }

        displayedAdId = .interstitial(id: interstitialAdId)
        interstitial.present(fromRootViewController: viewController)

        return true
    }

    // MARK: - Rewarded -

    /// Loads a rewarded video ad
    ///
    ///  - Throws: `GoogleAdsError.rewardedVideoLoadingFailed`, `GoogleAdsError.notInitialised`
    ///
    public func loadRewardVideo<T: Hashable>(_ type: T) async throws where T: Equatable {

        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let rewardedVideoAdId = try config.getRewardedVideoAdId(type)

        guard loadedRewardedVideos[rewardedVideoAdId] == nil else {
            return
        }

        do {
            let request = GADRequest()
            let ad = try await GADRewardedAd.load(withAdUnitID: rewardedVideoAdId,
                                                  request: request)
            ad.fullScreenContentDelegate = self
            loadedRewardedVideos[rewardedVideoAdId] = ad
        } catch {
            throw GoogleAdsError.rewardedVideoLoadingFailed
        }
    }

    /// Shows a rewarded ad
    ///
    /// - parameters:
    ///     - viewController:  A `UIViewController` to present the ad
    ///
    ///  - returns: `AdReward` or an throw error
    ///
    ///  - Throws: `GoogleAdsError.rewardedVideoNotLoaded`, `GoogleAdsError.notInitialised`, `rewardedVideoCantBePresented`
    ///
    @MainActor
    public func showRewardVideo<T: Hashable>(_ type: T,
                                             fromRootViewController viewController: UIViewController) async throws -> AdReward where T: Equatable {
        guard isInitialized else {
            throw GoogleAdsError.notInitialised
        }

        let rewardedVideoAdId = try config.getRewardedVideoAdId(type)

        // TODO: Custom way to load reward if didn't
        if let _ = loadedRewardedVideos[rewardedVideoAdId] {}
        else {
            try await loadRewardVideo(type)
        }

        guard let rewardedVideo = loadedRewardedVideos[rewardedVideoAdId] else {
            throw GoogleAdsError.rewardedVideoNotLoaded
        }

        displayedAdId = .rewardedVideo(id: rewardedVideoAdId)

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try rewardedVideo.canPresent(fromRootViewController: viewController)
            } catch {
                continuation.resume(with: .failure(GoogleAdsError.rewardedVideoCantBePresented))
            }

            rewardedVideo.present(fromRootViewController: viewController) {
                let reward = rewardedVideo.adReward
                let adReward = AdReward(amount: reward.amount.intValue, type: reward.type)
                continuation.resume(with: .success(adReward))
            }
        }
    }
}
