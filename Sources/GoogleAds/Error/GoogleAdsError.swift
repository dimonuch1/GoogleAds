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
}
