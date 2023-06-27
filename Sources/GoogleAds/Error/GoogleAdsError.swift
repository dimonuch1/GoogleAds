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

    // TODO:
    case rewardedTypeNotEqual
    case rewardedVideoNotInitialisedInConfig

    case interstitialTypeNotEqual
    case interstitialNotInitialisedInConfig
}

extension GoogleAdsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rewardedVideoNotInitialisedInConfig:
            return "Reward not initialised in config file"
        case .rewardedVideoNotLoaded:
            return "Reward not loaded"
        default: return "Custom error"
        }
    }
}
