//
//  GoogleAds.swift
//
//
//  Created by Koliush Dmitry on 23.07.2022.
//

import AppTrackingTransparency
import GoogleMobileAds
import Combine

///  Class provide you show google ads in swiftui view
public class GoogleAds<H: Hashable>: NSObject, GADFullScreenContentDelegate  {

//    public typealias Model = H

//    private var fullScreenAdsPresented = PassthroughSubject<Bool, Error>()
//    /// A publisher of whether an ad is presented fullscreen
//    private lazy var fullScreenAdsPresentedPublisher: AnyPublisher<Bool, Error> =
//        fullScreenAdsPresented.eraseToAnyPublisher()

    var loadedInterstitials = [String: GADInterstitialAd]()
    var loadedRewardedVideos = [String: GADRewardedAd]()

    var isInitialized = false
    let config: GoogleAdsConfig<H>
    var displayedAdId: DisplayedAdType?

    public weak var adsFullScreenContentDelegate: ADSFullScreenContentDelegate?

    public init(config: GoogleAdsConfig<H>) {
        self.config = config
    }

    enum DisplayedAdType: Equatable {
        case interstitial(id: String)
        case rewardedVideo(id: String)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.interstitial(let lhsValue), .interstitial(let rhsValue)),
                (.rewardedVideo(let lhsValue), .rewardedVideo(let rhsValue)):
                return lhsValue == rhsValue
            default: return false
            }
        }
    }

// MARK: - GADFullScreenContentDelegate -

    public func ad(_ ad: GADFullScreenPresentingAd,
                   didFailToPresentFullScreenContentWithError error: Error) {
        adsFullScreenContentDelegate?.ad(ad, didFailToPresentFullScreenContentWithError: error)
//        fullScreenAdsPresented.send(completion: .failure(error))
    }

    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adWillPresentFullScreenContent(ad)
        removeDisplayedAd()

//        fullScreenAdsPresented.send(true)
    }

    private func removeDisplayedAd() {
        guard let displayedAdId = displayedAdId else { return }

        switch displayedAdId {
        case .interstitial(let id):
            _ = loadedInterstitials.removeValue(forKey: id)

        case .rewardedVideo(let id):
            _ = loadedRewardedVideos.removeValue(forKey: id)
        }

        self.displayedAdId = nil
    }

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidDismissFullScreenContent(ad)
//        fullScreenAdsPresented.send(false)
    }

    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adWillDismissFullScreenContent(ad)
    }

    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidRecordClick(ad)
    }

    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adsFullScreenContentDelegate?.adDidRecordImpression(ad)
    }
}
