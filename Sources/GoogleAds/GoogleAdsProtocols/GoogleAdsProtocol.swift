//
//  GoogleAdsProtocol.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation
import Combine
import UIKit

// MARK: - Combine -
///  Protocol for working with `GoogleAds` service using the `Combine` methods style
///
///  Don't forget set `adsFullScreenContentDelegate` if you want recive `GADFullScreenContentDelegate` callbacks
///
public protocol GoogleAdsCombinePresenter {

    ///  Delegate property wich you set for receive callbacks from `GADFullScreenContentDelegate`
    ///
    var adsFullScreenContentDelegate: ADSFullScreenContentDelegate? { get set }

    /// Requests tracking authorization to deliver personalized ads
    func requestTrackingAuthorization() -> AnyPublisher<Bool, Error>


    /// Configures the Google Ads App
    ///
    ///  - returns: A publisher of whether the start is successful or an error
    ///
    func configure() -> AnyPublisher<Bool, Error>

    /// Loads an interstitial ad
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    func loadIntestitial() -> AnyPublisher<Bool, Error>

    /// Shows an interstitial ad
    ///
    /// - Parameters:
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - Returns: A publisher of whether the display is successful or an error
    ///
    func showInterstitial(fromRootViewController viewController: UIViewController) -> AnyPublisher<Bool, Error>

    /// Loads a rewarded video ad
    ///
    ///  - returns: A publisher of whether the load is successful or an error
    ///
    func loadRewardVideo() -> AnyPublisher<Bool, Error>

    /// Shows a rewarded ad
    ///
    /// - parameters:
    ///     - viewController: A `UIViewController` to present the ad
    ///
    ///  - returns: A publisher of the `AdReward` or an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    ///
    func showRewardVideo(fromRootViewController viewController: UIViewController) -> AnyPublisher<AdReward, Error>
}

public extension GoogleAdsCombinePresenter {

    /// Shows a rewarded ad
    ///
    ///  - returns: A publisher of the `AdReward` or an `Error`. You receive the `AdReward` just after the ad has been viewed and can earn reward amount
    ///
    func showRewardVideo() -> AnyPublisher<AdReward, Error> {
        guard let rootController = UIViewController.root else {
            return Fail(error: GoogleAdsError.rootControllerDidntFind)
                .eraseToAnyPublisher()
        }
        return showRewardVideo(fromRootViewController: rootController)
    }
}

// MARK: - Concurrency -
///  Protocol for working with `GoogleAds` service using the `Concurrency` methods style
///
///  Don't forget set `adsFullScreenContentDelegate` if you want recive `GADFullScreenContentDelegate` callbacks
///
public protocol GoogleAdsConcurrencyProtocol {
    ///  Delegate property wich you set for receive callbacks from `GADFullScreenContentDelegate`
    ///
    var adsFullScreenContentDelegate: ADSFullScreenContentDelegate? { get set }
    func configure() async
    func loadIntestitial() async throws
    func showInterstitial(fromRootViewController viewController: UIViewController) async throws -> Bool
    func loadRewardVideo() async throws
    func showRewardVideo(fromRootViewController viewController: UIViewController) async throws -> AdReward
}
