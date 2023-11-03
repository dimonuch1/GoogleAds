//
//  GoogleAdsCombinePresenter.swift
//  
//
//  Created by Koliush Dmytro on 26.06.2023.
//

import Foundation
import Combine
import UIKit
import AppTrackingTransparency

// MARK: - Combine -

///  Protocol for working with `GoogleAds` service using the `Combine` methods style
///
///  Don't forget set `adsFullScreenContentDelegate` if you want receive `GADFullScreenContentDelegate` callbacks
///
public protocol GoogleAdsCombinePresenter {

    ///  Delegate property which you set for receive callbacks from `GADFullScreenContentDelegate`
    ///
    var adsFullScreenContentDelegate: ADSFullScreenContentDelegate? { get set }

    /// Requests tracking authorisation to deliver personalised ads
    func requestTrackingAuthorization() -> AnyPublisher<ATTrackingManager.AuthorizationStatus, Error>

    func umpRequest(fromRootViewController viewController: UIViewController) -> AnyPublisher<Bool, Error>


    /// Configures the Google Ads App. Should be called as soon as possible, before show ad
    ///
    ///  - returns: A publisher of whether the start is successful or an error
    ///
    func configure() -> AnyPublisher<Bool, Error>

    /// Load an interstitial ad
    ///
    /// - Parameters:
    ///     - type: Loaded interstitial type. Usually it's **enum** type
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    func loadInterstitial<T: Hashable>(_ type: T) -> AnyPublisher<Bool, Error> where T: Equatable

    /// Refresh all ads
    ///
    /// Delete loaded ads and load new
    ///
    /// - returns: A publisher of whether the load is successful or an error
    ///
    func refreshAllLoadedAds() -> AnyPublisher<Bool, Error>

    /// Show an interstitial ad
    ///
    /// - Parameters:
    ///     - type: Showed interstitial type. Usually it's **enum** type
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - Returns: A publisher of whether the display is successful or an error
    ///
    func showInterstitial<T: Hashable>(
        _ type: T,
        fromRootViewController viewController: UIViewController) -> AnyPublisher<Bool, Error>

    /// Load a rewarded video ad
    ///
    ///  - Parameters:
    ///     - type: Loaded reward type. Usually it's **enum** type
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    func loadRewardVideo<T: Hashable>(_ type: T) -> AnyPublisher<Bool, Error>

    /// Show a rewarded ad
    ///
    /// - Parameters:
    ///     - type: Showed reward type. Usually it's **enum** type
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - returns: A publisher of the `AdReward` or an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    ///
    func showRewardVideo<T: Hashable>(
        _ type: T,
        fromRootViewController viewController: UIViewController) -> AnyPublisher<AdReward, Error>
}

public extension GoogleAdsCombinePresenter {

    /// Show a rewarded ad in default `UIViewController`
    ///
    /// - Parameters:
    ///     - type: Showed reward type. Usually it's **enum** type
    ///
    ///  - returns: A publisher of the `AdReward` or an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    ///
    func showRewardVideo<T: Hashable>(_ type: T) -> AnyPublisher<AdReward, Error> {
        guard let rootController = UIViewController.root else {
            return Fail(error: GoogleAdsError.rootControllerDidntFind)
                .eraseToAnyPublisher()
        }
        return showRewardVideo(type, fromRootViewController: rootController)
    }
}
