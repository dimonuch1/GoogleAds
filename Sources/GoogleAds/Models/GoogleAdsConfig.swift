//
//  GoogleAdsConfig.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation

/// Contains GoogleAds needed data
public struct GoogleAdsConfig<H: Hashable> where H: Equatable {

    /// The interstitial videos ad id
    let interstitial: String

    /// The identifiers of the devices used for testing
    let testDeviceIdentifiers: [String]

    public let rewardedVideos: [H: String]

    public init(interstitial: String,
                testDeviceIdentifiers: [String],
                rewardedVideos: [H: String] = [:]) {
        self.interstitial = interstitial
        self.testDeviceIdentifiers = testDeviceIdentifiers
        self.rewardedVideos = rewardedVideos
    }

    /// Tries to retrieve the type specific ad id otherwise uses the default id
    ///
    ///  - returns: An interstitial id
    ///
    func getInterstitialAdId() -> String {
        interstitial
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
            throw GoogleAdsError.rewardedVideoNotInitializedInConfig
        }
        throw GoogleAdsError.rewardedTypeNotEqual
    }
}
