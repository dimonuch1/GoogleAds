//
//  GoogleAdsConfig.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation

/// Contains GoogleAds needed data
public struct GoogleAdsConfig {

    /// The interstitial videos ad id
    let interstitial: String
    /// The reward videos ad id
    let rewardVideo: String
    /// The identifiers of the devices used for testing
    let testDeviceIdentifiers: [String]

    public init(interstitial: String,
                rewardVideo: String,
                testDeviceIdentifiers: [String]) {
        self.interstitial = interstitial
        self.rewardVideo = rewardVideo
        self.testDeviceIdentifiers = testDeviceIdentifiers
    }

    /// Tries to retrive the type specific ad id otherwise uses the default id
    ///
    ///  - returns: An interstitial id
    ///
    func getInterstitialAdId() -> String {
        interstitial
    }

    /// Tries to retrive the type specific ad id otherwise uses the default id
    ///
    ///  - returns: An reward video id
    ///
    func getRewardedVideoAdId() -> String {
        rewardVideo
    }
}
