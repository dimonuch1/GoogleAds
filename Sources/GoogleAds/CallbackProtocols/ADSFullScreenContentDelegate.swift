//
//  ADSFullScreenContentDelegate.swift
//  
//
//  Created by Koliush Dmitry on 23.02.2023.
//

import Foundation
import GoogleMobileAds

/// Delegate methods for receiving notifications about presentation and dismissal of full screen
/// content. Full screen content covers your application's content. The delegate may want to pause
/// animations or time sensitive interactions. Full screen content may be presented in the following
/// cases:
/// 1. A full screen ad is presented.
/// 2. An ad interaction opens full screen content.
///
/// P.S. Used for ad as `Interstitial`, `Rewarded`.
public protocol ADSFullScreenContentDelegate: AnyObject {

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd)

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd)

    /// Tells the delegate that the ad will dismiss full screen content.
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd)

    /// Tells the delegate that a click has been recorded for the ad.
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd)

    /// Tells the delegate that an impression has been recorded for the ad.
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd)

}

extension ADSFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {}

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {}

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {}

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {}

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {}

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {}
}
