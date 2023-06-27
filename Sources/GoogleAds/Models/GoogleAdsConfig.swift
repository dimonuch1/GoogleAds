//
//  GoogleAdsConfig.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation

/// Contains GoogleAds needed data
public struct GoogleAdsConfig<H: Hashable, I: Hashable> where H: Equatable, I: Equatable {

    /// The identifiers of the devices used for testing
    let testDeviceIdentifiers: [String]

    /// The interstitial ad ids
    public let interstitialVideos: [I: String]

    /// The reward ad ids
    public let rewardedVideos: [H: String]

    public init(
                testDeviceIdentifiers: [String],
                interstitialVideos: [I: String] = [:],
                rewardedVideos: [H: String] = [:]
    ) {
        self.testDeviceIdentifiers = testDeviceIdentifiers
        self.rewardedVideos = rewardedVideos
        self.interstitialVideos = interstitialVideos
    }

    /// Tries to retrieve the type specific ad id otherwise uses the default id
    ///
    ///  - returns: An interstitial id
    ///
    func getInterstitialAdId<T: Hashable>(_ type: T) throws -> String where T: Equatable {
        if let type = type as? I {
            if let value = interstitialVideos[type] {
                return value
            }
            throw GoogleAdsError.interstitialNotInitialisedInConfig
        }
        throw GoogleAdsError.interstitialTypeNotEqual
    }

    /// Tries to retrieve the type specific ad id
    ///
    ///  - returns: An reward video id
    ///
    func getRewardedVideoAdId<T: Hashable>(_ type: T) throws -> String where T: Equatable {
        if let type = type as? H {
            if let value = rewardedVideos[type] {
                return value
            }
            throw GoogleAdsError.rewardedVideoNotInitialisedInConfig
        }
        throw GoogleAdsError.rewardedTypeNotEqual
    }
}
