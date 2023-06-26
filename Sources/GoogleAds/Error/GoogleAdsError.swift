//
//  GoogleAdsError.swift
//  
//
//  Created by Koliush Dmitry on 10.02.2023.
//

import Foundation

public enum GoogleAdsError: Error {
    case notInitialized

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
    case rewardedVideoNotInitializedInConfig
}

extension GoogleAdsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rewardedVideoNotInitializedInConfig:
            return "Reward not initialised in config file"
        case .rewardedVideoNotLoaded:
            return "Reward not loaded"
        default: return "Custom error"
        }
    }
}
