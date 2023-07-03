# GoogleAds

Simple library for working with GoogleAds. 

Contain simple methods like config, load, and show ads.

## Installation

#### Using as a dependency

#### Adding it to an existing iOS Project via Swift Package Manager

1. Using Xcode 11 or greater go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: `https://github.com/dimonuch1/GoogleAds.git`
3. Click on Next and select the project target

## Usage example

```swift
import GoogleAds
import Combine

class MyClass {

  private let interstitials: [Interstitial: String] = [
          .interstitial: "ca-app-pub-3940256099942544/4411468910"]
  private let rewarded: [Rewarded: String] = [
          .rewardedVideo: "ca-app-pub-3940256099942544/1712485313"]
  
  var googleAdsConcurrency: GoogleAdsConcurrencyProtocol
  var googleAdsCombine: GoogleAdsCombinePresenter

  var subscriptions: Set<AnyCancellable> = []

  init() {
    let config = GoogleAdsConfig<Rewarded, Interstitial>(
                  testDeviceIdentifiers: ["ee1cfa16d27babbf81cee7b56c5d7970"],
                  interstitialVideos: interstitials,
                  rewardedVideos: rewarded)
  
    googleAdsConcurrency = GoogleAds(config: config)
    googleAdsCombine = GoogleAds(config: config)
  
    // Concurrency configuration
      Task {
        try await googleAdsConcurrency.configure()
      }
  
    // Combine configuration
      googleAdsCombine.configure()
                .sink { _ in }
                  receiveValue: { _ in }
                .store(in: &subscriptions)

  }

// MARK: - Concurrency methods
  func showInterstitial(_ type: Interstitial) async {
    do {
      let result = try await googleAdsConcurrency.showInterstitial(type)
    } catch {}
  }
  
  func showReward(_ type: Rewarded) async {
    do {
      let reward = try await googleAdsConcurrency.showRewardVideo(type)
    } catch {}
  }

  // MARK: - Combine methods
    func showInterstitial(_ type: Interstitial) {
      googleAdsCombine
        .showInterstitial(type)
        .sink { _ in }
          receiveValue: { _ in }
        .store(in: &subscriptions)
    }
    
    func showReward(_ type: Rewarded) {
      googleAdsCombine
        .showRewardVideo(type)
        .sink { _ in }
          receiveValue: { _ in }
        .store(in: &subscriptions)
    }
}

enum Rewarded {
    case rewardedVideo
}

enum Interstitial {
    case interstitial
}

```

## Versions

1.0.0 - swift-package-manager-google-mobile-ads - v10.0.0
