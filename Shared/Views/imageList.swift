//
//  imageList.swift
//  WallsAi
//
//  Created by Jonathan Njilay on 2022-07-19.
//

import SwiftUI
import Firebase
import FirebaseStorage
import Kingfisher
import Foundation
import Vision
//import CachedAsyncImage


struct imageList: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager

    var catList : [String]
    @State var imageLists : [String] = [""]
    @State var getInageLists1: [String] = [""]
    @State var getInageLists3: [String: [String : String]] = [String: [String : String]]()
    @State var listofImage : [AsyncImagePhase] = []
    @State private var showSheet : Bool?
    @State private var showSheetS = false
    @State var showListOfImages : Bool = false
    @State var imagelink : URL? = nil
    @State var depthimagelink : URL!
    @State var showFav = false
    let userDefaults = UserDefaults.standard
    @State var imageLink = URL(string:"https://firebasestorage.googleapis.com/v0/b/walls-88b92.appspot.com/o/Wallpapers%2FIMG_3806.JPG?alt=media&token=4b1edd6a-6bf9-4720-b608-ad1878dccc84")
    
    @State private var selectedImage: URL?
    @State private var selectedImageString : String?

    
    @State var showRewardedAd: Bool = false
    @State var showIntersitialAd: Bool = false
    @State var rewardGranted: Bool = false
    
    
    @State var detectedPerson1: [Int:UIImage?] = [:]
    @State var detectedPerson2: [Int:UIImage?] = [:]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    @State var coverData: CoverData?

    
    var body: some View {
        
        let sorted3 = getInageLists3.sorted { $0.key > $1.key }
        
        GeometryReader{ bounds in
                
                ZStack {

                    ScrollView {
                        
//                        LazyVGrid(columns: columns, spacing: 0) {
//                            LazyVGrid(columns: [columns(.adaptive(minimum: 50))]) {
                                LazyVGrid(columns: columns, alignment: .center, spacing: 15
                                ) {

                            if showFav {
                                
                                let myFavs = userDefaults.object(forKey: "myFav") as? [String: String] ?? [:]
                                                                
                                ForEach(Array(myFavs.enumerated()), id: \.0) { index, itemss in
                                    
                                    ZStack {
                                        let url = URL(string: itemss.key)
                                        let depthurl = URL(string: itemss.value)
                                        let name  : String = itemss.key

                                        let _ = print("printing names ", name)
                                        Button(action: {
                                            coverData = CoverData( imageName: name,imagelink: url!, depthimagelink: depthurl!)
                                        }) { getListImage(for: url, Depthurl: depthurl, bounds : bounds) }
                                            .fullScreenCover(item: $coverData, onDismiss: didDismiss) { details in
                                                imageView(urlString: details.imagelink, depthString: details.depthimagelink, imageName: details.imageName)}
                                    }
                                    
                                }.navigationTitle("Favourites")
                                
                            } else{
                                
                               
                                if showListOfImages  == true {
                                    
                                    ForEach(Array(getInageLists3.enumerated()), id: \.offset) { index, element in
                                        ZStack {
                                            
                                            let urls  : URL = URL(string: element.value.keys.first!)!
                                            let urls2 : URL = URL(string: element.value.values.first!)!
                                            let name  : String = element.key

                                            Button(action: { coverData = CoverData( imageName: name, imagelink: urls, depthimagelink: urls2) }) {
                                                
                                                getListImage(for: urls, Depthurl: urls2, bounds : bounds)//.padding(.leading, 5)
                                                
                                            }
                                            .fullScreenCover(item: $coverData, onDismiss: didDismiss) { details in
                                                imageView(urlString: details.imagelink, depthString: details.depthimagelink, imageName: details.imageName)
                                                 }
                                        }

                                }.navigationTitle(catList[0])
                                } else {}
                            }
                            
                            
                        }.padding(10).onAppear(){ if showFav {} else { getList()} }
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
        
        }
    }
    
func didDismiss() { coverData = nil }
 
func loadScreensPush(for image: String, bounds : GeometryProxy) -> some View {
            Image(image)
                .resizable()
                .animation(.easeInOut(duration: 2), value: 1.0)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)

                .scaledToFill()

                .clipped()
}
    
func getListImage(for url: URL?, Depthurl: URL?, bounds : GeometryProxy) -> some View {
        
    ZStack {
        
        KFImage.url(url)
            .placeholder { ProgressView() }
            .resizable()
            .onSuccess { result in}
            .loadDiskFileSynchronously()
            .fade(duration: 2.25)
            .onProgress { receivedSize, totalSize in }
            .onFailure { error in }
            .cancelOnDisappear(false)
//            .edgesIgnoringSafeArea(.all)
            .scaledToFill()
//            .frame(minWidth: 0, maxWidth: (bounds.size.width)*0.5)
            .frame(width: bounds.size.width*0.46, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.46, alignment: .center).cornerRadius(15).clipped()

            .overlay() {
                
                if Depthurl == url {} else {
                    if !UIDevice.isIPhone {} else {
                        if !UIDevice.current.hasNotch {} else {
                            
                            loadScreensPush(for: UIDevice.isIPhone ? "IOS16LOOCKSCREENX1" : "IOS16LOOCKSCREENX4", bounds: bounds)
                            
                            KFImage.url(Depthurl)
                                .placeholder { ProgressView() }
                                .resizable()
                                .onSuccess { result in }
                                .loadDiskFileSynchronously()
                                .fade(duration: 2.25)
                                .onProgress { receivedSize, totalSize in }
                                .onFailure { error in }
                                .cancelOnDisappear(false)
                                .scaledToFill()
                                .frame(width: bounds.size.width*0.46, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.46, alignment: .center).cornerRadius(15).clipped()
                            
                        }}}
            }

    }
    }
    
    
    func getList() {
        
        self.getInageLists1.removeAll()
        self.getInageLists3.removeAll()
        let db = Firestore.firestore()
        
        db.collection("Wallpapers").whereField("categories", arrayContains: catList[0]).limit(to: 500).getDocuments { (querySnapshot, error) in
            if let error = error { print("print 2 error", error) } else {
                for document in querySnapshot!.documents {
                    let image = document.documentID
                    
                    let dictionary = [".JPG": "", ".PNG": "", ".WEBP": ""]
                    let depthLink = image.replace(dictionary)
                    let depthname = "\(depthLink).PNG"

                    let categories = document.get("categories") as! Array<String>
                    let showDepth = categories.contains("Depth Effect") ? true : false
                    let Wallpapersstorage = Storage.storage().reference(withPath: "Wallpapers/\(image)")
                    let Depthimagestorage = Storage.storage().reference(withPath: "Depth/\(depthname)")

                    Wallpapersstorage.downloadURL { (Wallpapersurl, error) in
                            if error != nil { return }
                            
                        Depthimagestorage.downloadURL { (Depthimageurl, error) in
                            if error != nil {  }
                            
                            
                            let imageUrl = ("\(Wallpapersurl!)")
                            let Depthimage = ("\(Depthimageurl ?? Wallpapersurl!)")
                            getInageLists3[image] = [imageUrl: Depthimage]
                            
                            if getInageLists3.count == querySnapshot?.count { showListOfImages = true } else {}
                            print("print getInageLists2", depthname)
                        }
                        }
                }}}}
    
}

struct imageList_Previews: PreviewProvider {
    static var previews: some View {
        imageList(catList: ["Monterey Left.heic"])
    }
}
