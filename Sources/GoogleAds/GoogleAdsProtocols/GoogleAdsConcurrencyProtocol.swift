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
    func configure() async
    func loadInterstitial<T: Hashable>(_ type: T) async throws -> Void where T: Equatable
    @discardableResult
    func showInterstitial<T: Hashable>(_ type: T,
                          fromRootViewController viewController: UIViewController) async throws -> Bool
    func loadRewardVideo<T: Hashable>(_ type: T) async throws -> Void where T: Equatable
    func showRewardVideo<T: Hashable>(_ type: T,
                                      fromRootViewController viewController: UIViewController) async throws -> AdReward where T: Equatable
    @discardableResult
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus
}
