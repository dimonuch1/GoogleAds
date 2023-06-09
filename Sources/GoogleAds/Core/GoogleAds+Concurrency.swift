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
    ///  - Returns: A `Bool` value of whether the display is successful or throws `Error`
    ///
    @MainActor
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

        guard loadedRewardedVideos[rewardedVideoAdId] == nil else {
            return
        }

        let request = GADRequest()
        do {
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
    ///  - Throws: `GoogleAdsError.rewardedVideoNotLoaded`, `GoogleAdsError.notInitialized`, `rewardedVideoCantBePresented`
    ///

    @MainActor
    public func showRewardVideo(fromRootViewController viewController: UIViewController) async throws -> AdReward {
        guard isInitialized else {
            throw GoogleAdsError.notInitialized
        }

        let rewardedVideoAdId = config.getRewardedVideoAdId()

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
                continuation.resume(returning: adReward)
            }
        }
    }
}
