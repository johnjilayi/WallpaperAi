//
//  imageView.swift
//  WallsAi
//
//  Created by Jonathan Njilay on 2022-07-18.
//
import UIKit
import SwiftUI
import Kingfisher
import Foundation
import Firebase
import FirebaseStorage
import GoogleMobileAds
import Vision

import Drops

struct imageView: View {
    
    
//    private let coordinator = InterstitialAdCoordinator()
//    private let newcoordinator = InterstitialAd()
//    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @State var detectedPerson3: [Int:UIImage?] = [:]

    var adViewControllerRepresentableView: some View {
        firestoreManager.adViewControllerRepresentable
        .frame(width: .zero, height: .zero)
    }
    
    
//    @Published var interstitial = Interstitial()
    @EnvironmentObject var firestoreManager: FirestoreManager

    var urlString = URL(string: "")
    var depthString : URL!
    var showFeatured : Bool =  true
    
    @ObservedObject var viewModel = ListViewModel()
    @State var isActive = false

    let userDefaults = UserDefaults.standard

    @State var saveImage = UIImage()

    @State private var selectedButton = ""
    
    @State var showRewardedAd: Bool = false
    @State var showIntersitialAd: Bool = false
    @State var rewardGranted: Bool = false
    
    var imageName : String = "IMG_3806.JPG"

    var showDepth : Bool = true

    
    let sx = CGFloat(UIScreen.screenWidth/3)
    
    @State var showLockScreen = true
    @State var showHomeScreen = true
    @State var italic = false
    @State var underline = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject var manager = MotionManager()

    @State var detectedPerson1: [Int:UIImage?] = [:]
    @State var detectedPerson2: [Int:UIImage?] = [:]
    
    
    var body: some View {
        
        GeometryReader{ bounds in
            
            getListImage(for: urlString, Depthurl: depthString, bounds : bounds)
                .onTapGesture { showLockScreen.toggle() }

            ZStack {
                Text("Hold to add or remove from Favourites").font(.footnote).fontWeight(.light).foregroundColor(.white.opacity(1)).shadow(radius: 2).frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight, alignment: .bottom).padding(.bottom, sx*0.4+(UIDevice.isIPhone ? UIScreen.screenWidth*0.2 : UIScreen.screenWidth*0.1)+45)
                bottomBar()
                
            }

            .background(adViewControllerRepresentableView)
            
            
            HStack {  if showFeatured {
                Button(action: { saveFeartured() }) { Image(systemName: "star.fill") }
            .padding(.leading, 15).padding(.top, 5).frame(minWidth: 50, maxWidth: 50, alignment: .leading)
                
            }
                
            }
            
        }

        .onLongPressGesture { saveFav() }
        
        .onAppear() {
            firestoreManager.newcoordinator.LoadInterstitial()   }
        
        .onDisappear() {
//            firestoreManager.newcoordinator.showAd(from: firestoreManager.adViewControllerRepresentable.viewController)
        }
        .preferredColorScheme(.dark)
        
    }

    
    func bottomBar() -> some View {
        
        
        HStack { Group {
            
            if !UIDevice.current.hasNotch {} else {
                
                if depthString == urlString {} else { //showLockScreen.toggle()
                    
                    Button(action: { showHomeScreen.toggle()
                        simpleSuccess() }) {Image(systemName: "apps.iphone").resizable().scaledToFit().frame(width: sx*0.3, height: sx*0.3)
                            .foregroundColor(!showHomeScreen ? .white : Color.black) }
                }}
            
            Button(action: { savingIMage() }) { Image(systemName: "square.and.arrow.down").resizable().scaledToFit().frame(width: sx*0.3, height: sx*0.3).foregroundColor(.black) }
                
            Button(action: { underline.toggle()
                showHomeScreen.toggle()
                    simpleSuccess()
                    presentationMode.wrappedValue.dismiss()
                }) { Image(systemName: "x.circle").resizable().scaledToFit().frame(width: sx*0.3, height: sx*0.3).foregroundColor(.black) }
            }.buttonStyle(GrayButtonStyle(w: sx*0.4, h: sx*0.4)).padding(15) }
            .clipped(antialiased: true)
            .cornerRadius(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, UIDevice.isIPhone ? UIScreen.screenWidth*0.2 :  UIScreen.screenWidth*0.1)//.padding(.top, 15)
        
    }
    
   public func savingIMage() {
        print("deviceModel 2")

        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            showIntersitialAd.toggle()
            Drops.show("Saved To Photos")
            simpleSuccess()
            firestoreManager.newcoordinator.showAd2(from: firestoreManager.adViewControllerRepresentable.viewController)
        }

        imageSaver.writePhotoToAlbum(image: saveImage)
       
       saveFav()
    }
    
    
    func loadScreensPush(for image: String, bounds : GeometryProxy) -> some View {
            Image(image)
                .resizable()
                .animation(.easeInOut(duration: 2), value: 1.0)
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
                .clipped()

    }
    
    
        
    func saveFeartured()  {
        print("saving featured with", imageName)
        let db = Firestore.firestore()
        let docRef = db.collection("Wallpapers").document(imageName)
        db.collection("Wallpapers").document(imageName).getDocument { ocumentSnapshot, erro in
            
            var children: [String] = ocumentSnapshot!.data()!["categories"] as! [String]

            if children.contains("Featured") {
                print("includes ", imageName)
                if let index = children.firstIndex(of: "Featured") { children.remove(at: index) }
            } else { children.append("Featured") }
            
            docRef.updateData(["categories": children]) { error in
                if let error = error { print("Error writing document: \(error)")} else { print("Document successfully written!", imageName) }
            }
            Drops.show("Featured")
            simpleSuccess()
            
        }
    }
    
    func saveFav() {
    
        let urlLink = urlString!.absoluteString
        
        var strings: [String : String] = userDefaults.object(forKey: "myFav") as? [String: String] ?? [:]
        
        if strings.keys.contains(urlLink) {
            if let index = strings.keys.firstIndex(of: urlLink) {
                strings.remove(at: index)
                userDefaults.set(strings, forKey: "myFav")
                viewModel.myFavs.removeAll()
                Drops.show("Removed from favourite")
                simpleSuccess()
            }
        } else {
            strings[urlLink] = depthString?.absoluteString ?? urlLink
            userDefaults.set(strings, forKey: "myFav")  
            viewModel.myFavs.removeAll()
            viewModel.myFavs = userDefaults.object(forKey: "myFav") as? [String] ?? []
            Drops.show("Added To favourite")
            simpleSuccess()
        }
        
    }
    
    
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func getListImage(for url: URL?, Depthurl: URL?, bounds : GeometryProxy) -> some View {
        
        ZStack {
            
            KFImage.url(url)
                .placeholder { ProgressView() }
                .resizable()
                .onSuccess { result in saveImage = result.image
//                    firestoreManager.newcoordinator.showAd(from: firestoreManager.adViewControllerRepresentable.viewController)
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
                .scaledToFill()
                .frame(width: bounds.size.width, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom), alignment: .center)
            
                .overlay() {
                
                    if Depthurl == url {} else { //showLockScreen.toggle()
                        if bounds.safeAreaInsets.bottom == 0.0 && showHomeScreen {} else {
                            
                            loadScreensPush(for: showLockScreen ? showHomeScreen ?  ( UIDevice.isIPhone ? "IOS16LOOCKSCREENX1" : "IPAD16LOOCKSCREEN") : (UIDevice.isIPhone ? "IOS16HOMESCREEN" : "IOS16LOOCKSCREENX4") : "IOS16LOOCKSCREENX3", bounds: bounds)
                            
                            if !UIDevice.isIPhone {} else {
                                KFImage.url(Depthurl)
                                    .placeholder { ProgressView() }
                                    .resizable()
                                    .onSuccess { result in }
                                    .loadDiskFileSynchronously()
                                    .fade(duration: 2.25)
                                    .onProgress { receivedSize, totalSize in }
                                    .onFailure { error in }
                                    .cancelOnDisappear(false)
                                    .edgesIgnoringSafeArea(.all)
                                    .ignoresSafeArea(.all)
                                    .scaledToFill()
                                    .frame(width: bounds.size.width, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom), alignment: .center)
                                
                            }
                            
                            
                            loadScreensPush(for: showLockScreen ? showHomeScreen ?  ( UIDevice.isIPhone ? "IOS16LOOCKSCREENX2" : "IOS16LOOCKSCREENX4") : (UIDevice.isIPhone ? "IOS16HOMESCREEN" : "IOS16LOOCKSCREENX4") : "IOS16LOOCKSCREENX3", bounds: bounds)
                        }
                        
                    }
                    
                }
                                

            }
        
        
    }
    
    
        
    }


struct imageView_Previews: PreviewProvider {
    static var previews: some View {
        imageView(urlString: URL(string: "www.hi.com")!, imageName: "d")
            .previewInterfaceOrientation(.portrait)
    }
}
