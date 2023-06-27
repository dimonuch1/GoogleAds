//
//  GoogleAds+Combine.swift
//  
//
//  Created by Koliush Dmytro on 09.06.2023.
//

import AppTrackingTransparency
import GoogleMobileAds
import Combine

// MARK: - Combine Style -
extension GoogleAds: GoogleAdsCombinePresenter {

    /// Requests tracking authorisation to deliver personalised ads
    ///
    ///  - returns: A publisher of whether the access is granted
    ///
    public func requestTrackingAuthorization() -> AnyPublisher<ATTrackingManager.AuthorizationStatus, Error> {
        Future<ATTrackingManager.AuthorizationStatus, Error> { promise in
            // Bug from iOS 15. Needed some delay before request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization {
                    promise(.success($0))
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

    public func loadInterstitial<T: Hashable>(_ type: T) -> AnyPublisher<Bool, Error> where T: Equatable {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised)
                .eraseToAnyPublisher()
        }

        var interstitialAdId: String

        do {
            interstitialAdId = try config.getInterstitialAdId(type)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

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

    public func showInterstitial<T: Hashable>(
        _ type: T,
        fromRootViewController viewController: UIViewController
    ) -> AnyPublisher<Bool, Error>{
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        var interstitialAdId: String

        do {
            interstitialAdId = try config.getInterstitialAdId(type)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        guard let interstitial = loadedInterstitials[interstitialAdId] else {
            return Fail(error: GoogleAdsError.interstitialNotLoaded).eraseToAnyPublisher()
        }

        displayedAdId = .interstitial(id: interstitialAdId)
        interstitial.present(fromRootViewController: viewController)

        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // MARK: Rewarded Ads
    public func loadRewardVideo<T: Hashable>(_ type: T) -> AnyPublisher<Bool, Error> {
        guard isInitialized else {
            return Fail<Bool, Error>(error: GoogleAdsError.notInitialised)
                .eraseToAnyPublisher()
        }

        let rewardedVideoAdId: String

        do {
            rewardedVideoAdId = try config.getRewardedVideoAdId(type)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

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

    public func showRewardVideo<T: Hashable>(
        _ type: T,
        fromRootViewController viewController: UIViewController) -> AnyPublisher<AdReward, Error> {
        guard isInitialized else {
            return Fail<AdReward, Error>(error: GoogleAdsError.notInitialised).eraseToAnyPublisher()
        }

        let rewardedVideoAdId: String

        do {
            rewardedVideoAdId = try config.getRewardedVideoAdId(type)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

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
