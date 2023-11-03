//
//  GoogleAdsConcurrencyProtocol.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation
import Combine
import UIKit
import AppTrackingTransparency

// MARK: - Concurrency -

///  Protocol for working with `GoogleAds` service using the `Concurrency` methods style
///
///  Don't forget set `adsFullScreenContentDelegate` if you want receive `GADFullScreenContentDelegate` callbacks
///
public protocol GoogleAdsConcurrencyProtocol {

    ///  Delegate property which you set for receive callbacks from `GADFullScreenContentDelegate`
    ///
    var adsFullScreenContentDelegate: ADSFullScreenContentDelegate? { get set }

    /// Configures the Google Ads App. Should be called as soon as possible, before show ad
    ///
    func configure() async throws

//    func requestTrackingAuthorization() async throws

    func umpRequest(fromRootViewController viewController: UIViewController) async throws

    /// Refresh all ads
    ///
    /// Delete loaded ads and load new
    ///
    func refreshAllLoadedAdsAsync() async throws

    /// Load an interstitial ad
    ///
    /// - Parameters:
    ///     - type: Loaded interstitial type. Usually it's **enum** type
    ///
    func loadInterstitial<T: Hashable>(_ type: T) async throws where T: Equatable

    /// Show an interstitial ad
    ///
    /// - Parameters:
    ///     - type: Showed interstitial type. Usually it's **enum** type
    ///     - viewController: A `UIViewController` to present the ad
    ///
    /// - returns: True whether the display is successful or an error
    ///
    @discardableResult
    func showInterstitial<T: Hashable>(_ type: T,
                          fromRootViewController viewController: UIViewController) async throws -> Bool

    /// Load a rewarded video ad
    ///
    ///  - Parameters:
    ///     - type: Loaded reward type. Usually it's **enum** type
    ///
    func loadRewardVideo<T: Hashable>(_ type: T) async throws where T: Equatable

    /// Show a rewarded ad
    ///
    /// - Parameters:
    ///     - type: Showed reward type. Usually it's **enum** type
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - returns: `AdReward` or throw an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    ///
    func showRewardVideo<T: Hashable>(_ type: T,
                                      fromRootViewController viewController: UIViewController) async throws -> AdReward where T: Equatable

    /// Requests tracking authorisation to deliver personalised ads
    @discardableResult
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus
}

public extension GoogleAdsConcurrencyProtocol {

    /// Show a rewarded ad
    ///
    /// - Parameters:
    ///     - type: Showed reward type. Usually it's **enum** type
    ///
    ///  - returns: `AdReward` or throw an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    func showRewardVideo<T: Hashable>(_ type: T) async throws -> AdReward where T: Equatable {
        guard let rootController = await UIViewController.root else {
            throw GoogleAdsError.rootControllerDidntFind
        }
        return try await showRewardVideo(type, fromRootViewController: rootController)
    }
}
