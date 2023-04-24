//
//  AppDelegate.swift
//  WallsAi
//
//  Created by Jonathan Njilay on 2022-05-27.
//

import Foundation
import SwiftUI
import GoogleMobileAds


class AppDelegate: NSObject, UIApplicationDelegate {
    let userDefaults = UserDefaults.standard

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
           print(">> your code here !!")
           return true
       }
      
      var adsCount: Int = userDefaults.object(forKey: "myAdsCount") as? Int ?? 0
      adsCount = 0
      userDefaults.set(adsCount, forKey: "myAdsCount")
      
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ SwiftUIMobileAds.testIdentifiers ]
      return true
  }
}

//@main
struct YourApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
//      NavigationView {
        ContentView()
//      }
    }
  }
}
