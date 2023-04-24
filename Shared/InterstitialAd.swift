//
//  InterstitialAd.swift
//  Pomodoro
//
//  Created by Alfie on 16/08/2022.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Helper to present Interstitial Ad
 struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}


final class InterstitialAd : NSObject, GADFullScreenContentDelegate, ObservableObject {
    var interstitialAd: GADInterstitialAd?

    @Published var isLoaded: Bool = false
//    @EnvironmentObject var firestoreManager: FirestoreManager
    let userDefaults = UserDefaults.standard

    func LoadInterstitial() {        
        let request = GADRequest()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene

        GADInterstitialAd.load( withAdUnitID: SwiftUIMobileAds.testInterstitialId, request: request ) { ad, error in
          self.interstitialAd = ad
          self.interstitialAd?.fullScreenContentDelegate = self
        }
        
        
    }
    
    
    
    
    // Using user Defaults to track ad load amount
    func showAd (from root: UIViewController) {
//        @EnvironmentObject var firestoreManager: FirestoreManager
        var adsCount: Int = userDefaults.object(forKey: "myAdsCount") as? Int ?? 0

        if adsCount > 4 {
            adsCount = 0
            userDefaults.set(adsCount, forKey: "myAdsCount")
        }
        else if adsCount == 0 {
            adsCount = adsCount+1
            userDefaults.set(adsCount, forKey: "myAdsCount")
        }
        else if adsCount == 2 {
            adsCount = adsCount+1
            userDefaults.set(adsCount, forKey: "myAdsCount")
        }
        else if adsCount == 3 {
            adsCount = adsCount+1
            userDefaults.set(adsCount, forKey: "myAdsCount")
        }
//        else if adsCount == 4 {
//            adsCount = 0
//            userDefaults.set(adsCount, forKey: "myAdsCount")
//        }
        else {
            adsCount = adsCount+1
            userDefaults.set(adsCount, forKey: "myAdsCount")
            if let ad = interstitialAd { ad.present(fromRootViewController: root) } else { LoadInterstitial() }
        }

    }
    
    func showAd2 (from root: UIViewController) {
        if let ad = interstitialAd {
                  ad.present(fromRootViewController: root)
              } else {
                  LoadInterstitial()
              }
    }

    
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("did didFailToPresentFullScreenContentWithError ad", error.localizedDescription)
        
    }
    
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          print("did adWillPresentFullScreenContent ad")
      }

    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("did adDidRecordClick ad")

    }

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("did adDidRecordImpression ad")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("did adWillDismissFullScreenContent ad")
        LoadInterstitial()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("did adDidDismissFullScreenContent ad")
        interstitialAd = nil
    }
}
