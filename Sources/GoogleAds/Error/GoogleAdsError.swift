//
//  GoogleAdsError.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation

public enum GoogleAdsError: Error {
    case notInitialised

    case interstitialAdIdMissing
    case interstitialLoadingFailed
    case interstitialNotLoaded

    case rewardedVideoAdIdMissing
    case rewardedVideoLoadingFailed
    case rewardedVideoNotLoaded

    case rootControllerDidntFind

    case rewardedVideoCantBePresented

    case rewardedTypeNotEqual
    case rewardedVideoNotInitialisedInConfig

    case interstitialTypeNotEqual
    case interstitialNotInitialisedInConfig
}

extension GoogleAdsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notInitialised:
            return "Module not initialised"
        case .interstitialAdIdMissing:
            return "Interstitials are missing"
        case .interstitialLoadingFailed:
            return "Interstitial loading failed"
        case .interstitialNotLoaded:
            return "Interstitial has not loaded yet"
        case .rewardedVideoAdIdMissing:
            return "Rewarded video ad id missing"
        case .rewardedVideoNotInitialisedInConfig:
            return "Reward not initialised in config file"
        case .rewardedVideoNotLoaded:
            return "Reward not loaded"
        case .rootControllerDidntFind:
            return "Root controller hasn't found"
        case .rewardedVideoCantBePresented:
            return "Rewarded video cant be presented, some problem with controller"
        case .rewardedTypeNotEqual:
            return "Presented reward video type not equal to reward video type in config file"
        case .interstitialTypeNotEqual:
            return "Interstitial reward type not equal to interstitial reward in config file"
        case .interstitialNotInitialisedInConfig:
            return "Interstitial not initialised in config file"
        default: return "Custom error"
        }
    }
}
