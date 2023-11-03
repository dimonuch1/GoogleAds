//
//  GoogleAds+GoogleAdsConcurrencyProtocol.swift
//  
//
//  Created by Koliush Dmytro on 09.06.2023.
//

import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

// MARK: - Concurrency Style -
extension GoogleAds: GoogleAdsConcurrencyProtocol {

    // MARK: - Configure -

    public func configure() async throws {
        try await configureGoogleAdsApp()
    }

    public func requestTrackingAuthorization() async throws {
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else {
            throw URLError(.badURL)
        }

        if #available(iOS 16.0, *) {
            try await Task.sleep(for: Duration.seconds(2))
        }

        await ATTrackingManager.requestTrackingAuthorization()
    }

    public func umpRequest(fromRootViewController viewController: UIViewController) async throws {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        #if DEBUG
        UMPConsentInformation.sharedInstance.reset()
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["B26AA4EE-8880-408D-A75E-C8F8B04BA2F6"]
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        #endif

        try await UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters)
        let consent = try await UMPConsentForm.load()
        try await consent.present(from: viewController)
    }

    public func refreshAllLoadedAdsAsync() async throws {
        loadedRewardedVideos.removeAll()
        config.rewardedVideos.keys.forEach { value in
            Task {
                try? await self.loadRewardVideo(value)
            }
        }

        loadedInterstitials.removeAll()
        config.interstitialVideos.keys.forEach { value in
            Task {
                try? await self.loadInterstitial(value)
            }
        }
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

    private func configureGoogleAdsApp() async throws {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = config.testDeviceIdentifiers
        _ = await GADMobileAds.sharedInstance().start()
        isInitialized = true
        try await refreshAllLoadedAdsAsync()
    }

    // MARK: - Interstitial -

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

            print("Test Loaded interstitial: \(interstitialAdId)")
        } catch {
            throw GoogleAdsError.interstitialLoadingFailed
        }
    }

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

        // TODO: Custom way to load interstitial if didn't
        if let _ = loadedInterstitials[interstitialAdId] {}
        else {
            try await loadInterstitial(type)
        }

        guard let interstitial = loadedInterstitials[interstitialAdId] else {
            throw GoogleAdsError.interstitialNotLoaded
        }

        displayedAdId = .interstitial(id: interstitialAdId)
        interstitial.present(fromRootViewController: viewController)

        return true
    }

    // MARK: - Rewarded -

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
