//
//  WallsAi.swift
//  Shared
//
//  Created by Jonathan Njilay on 2022-05-24.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import Firebase

@main
struct WallsAi: App {
    @StateObject var firestoreManager = FirestoreManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    init() {
        ATTrackingManager.requestTrackingAuthorization { status in
            GADMobileAds.sharedInstance().start(completionHandler: nil) }
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firestoreManager)
                .onAppear() {
                    firestoreManager.fetchAllData()
                    firestoreManager.fetchFeatured()
                }
        }
    }
}
