//
//  FirestoreManager.swift
//  WallsAi
//
//  Created by Jonathan Njilay on 2022-05-28.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import GoogleMobileAds

class UserClass {
    var id = ""
    var name = ""
    var image = ""
    var Depthimage = ""
    var category = ""
    var children: [String] = []
    var children2: [String:String] = [:]
    var children3: [Array] = [[]]
    var categorylist: [Bool:String] = [:]
    var categories: [String] = []
    var tyrList: [String:Bool] = [:]
    var categorylist2: [String : [String:Bool]] = [:]
}

class postClass {
    var id = ""
    var names = ""
    var image = ""
    var item : Int = 0
    var loc : Int = 0
    var category = ""
    var children: [String] = []
    var images: [
        Int:UIImage] = [
            :]
    var categorylist: [Int:String] = [:]
}


class featuredItem {
    var id = ""
    var name = ""
    var imageUrl = ""
    var DepthimageUrl = ""
    var children: [String] = []
    var children2: [String] = []
    var children3: [Array] = [[]]
    var categorylist: [Bool:String] = [:]
    var tyrList: [String:Bool] = [:]
    var categorylist2: [String : [String:Bool]] = [:]
}


class FirestoreManager : ObservableObject {
    
     let newcoordinator = InterstitialAd()
     let adViewControllerRepresentable = AdViewControllerRepresentable()
    
    
    @Published var name : String = "lift"
    @Published var adsaCount : Int = 0
    @Published var listName : [String] = ["name"]
    @Published var catList : [String] = ["IXoRiZrov3WdfMWmGEU2", "RpzSni70OaXGk5YRtLtu", "bApkRQ0QBaYf2GoT4xR0"]
    
    @Published var catNames : [String] = [//"All",
                                          "Featured",
                                          "Depth Effect",
                                          "New",
                                          "Nature",
                                          "Lights",
                                          "City",
                                          "WildLife",
                                          "Cars",
                                          "Galaxy",
                                          "Clouds",
                                          "Mountains",
                                          "Sky",
                                          "Colorful",
                                          "Weather",
                                          "Dark",
                                          "Night",
                                          "Street",
                                          "Trees",
                                          "Plants",
                                          "Animals",
                                          "Flowers",
                                          "Travel",
                                          "Quotes",
                                          "Landscape",
                                          "Characters",
                                          "Island",
                                          "Abstract",
                                          "Sea",
                                          "Skyscraper",
                                          "Forest"]
    
    @Published var catNamesLess : [String] = ["Depth Effect",
                                              "New",
                                          "Nature",
                                          "City",
                                          "Galaxy",
                                          "Mountains",
                                          "Sky",
                                          "Colorful",
                                          "Dark",
                                          "Animals",
                                          "Flowers",
                                          "Quotes",
                                          "Characters",
                                          "Sea"]

    var dataArray = [UserClass]()
    var featuredArray = [featuredItem]()
    var listArray = [featuredItem]()
    var catArray = [featuredItem]()
    var selectedImage = Image("logo")

    @Published var multiDimDict: [String: [[String: [String]]]]?
    
    
    struct Post: Identifiable {
        var id = UUID().uuidString
        var postImage: String
    }
    
    
    func fetchAllData() {
        
        self.dataArray.removeAll()
                
        let db = Firestore.firestore()
        
//        for i in catNamesLess.count {
//        for i in catNamesLess.reversed() {
            for (i, item) in catNamesLess.enumerated() {


            db.collection("Wallpapers").whereField("categories", arrayContains: catNamesLess[i]).limit(to: 5).getDocuments { (querySnapshot, error) in
                var depthPic = [String]()

                if let error = error { print("print 11 error", error, self.catNamesLess[i], item) } else {
                        
                    let user = UserClass()
                    var imageNames = [String]()

                        for document in querySnapshot!.documents {
                            
//                            let id = document.documentID
                            let name = document.documentID
                            let image = document["image"] as! String

                            imageNames.append(name)

//                            user.id = id
                            user.name = name
                            user.image = image
                            user.category = self.catNamesLess[i]
                            
                            let arrays = document.get("categories") as! Array<String>

                            if arrays.contains("Depth Effect") { depthPic.append(name) } else {  }
                                
                            if imageNames.count == querySnapshot!.documents.count {
                                
                                for list in 0..<imageNames.count {
                                    
                                    let dictionary = [".JPG": "", ".PNG": "", ".WEBP": ""]
                                    let depthLink = imageNames[list].replace(dictionary)
                                    let depthname = "\(depthLink).PNG"
                                    
                                    let storage = Storage.storage().reference(withPath: "Wallpapers/\(imageNames[list])")
                                    let Depthimagestorage = Storage.storage().reference(withPath: "Depth/\(depthname)")

                                    storage.downloadURL { (url, error) in
                                        if error != nil { /*print("cant get image",(error?.localizedDescription)!);*/ return }
                                        
                                        Depthimagestorage.downloadURL { (Depthimageurl, error) in
                                            if error != nil {  }
                                            
                                            user.category = self.catNamesLess[i]
                                            user.children.append("\(url!)")
                                            user.children2["\(url!)"] = "\(Depthimageurl ?? url!)"
//                                            user.children.append("\(url!)")
                                            user.categories = document.get("categories") as! Array
                                            
                                            if depthPic.contains(imageNames[list]) { user.tyrList[url!.absoluteString] = true } else { user.tyrList[url!.absoluteString] = false }
                                            
                                            self.name = "close"
                                            
                                        }
                                    }
                                    
                                }
                                self.dataArray.append(user)
                                self.dataArray.reverse()

                            } else {}
                        }
                }
            }
        }
    }
    
    
    func fetchFeatured(){
        
        self.featuredArray.removeAll()
        let db = Firestore.firestore()
        var depthPic = [String]()

            db.collection("Wallpapers").whereField("categories", arrayContains: "Featured").limit(to: 10).getDocuments { (querySnapshot, error) in

                if let error = error { print("print error fetchFeatured", error) } else {
                    
                    for document in querySnapshot!.documents {
                        
                        let user = featuredItem()
                        
                        
                        let id = document.documentID
                        let name = document.get("name") as! String
                        user.id = id
                        user.name = name
                        user.children = document.get("categories") as! Array

                        let arrays = document.get("categories") as! Array<String>


                        if arrays.contains("Depth Effect") { // print("print it does", name)
                            depthPic.append(name)
//                            print("print it does", name, depthPic)
                        } else {  }
                            
//                        print("print arrays", name, depthPic, arrays, "----------", "Featured")

                        
                        let dictionary = [".JPG": "", ".PNG": "", ".WEBP": ""]
                        let depthLink = name.replace(dictionary)
                        let depthname = "\(depthLink).PNG"
                        
//                        print("print user.children 2", user.children)
                            let storage = Storage.storage().reference(withPath: "Wallpapers/\(name)")
                        let Depthimagestorage = Storage.storage().reference(withPath: "Depth/\(depthname)")

                            storage.downloadURL { (url, error) in
                                if error != nil { return }
                                
                                Depthimagestorage.downloadURL { (Depthimageurl, error) in
                                    if error != nil {  }
                                    
                                    user.imageUrl = ("\(url!)")
                                    user.DepthimageUrl = ("\(Depthimageurl ?? url!)")
                                    self.name = "close"
                                    self.featuredArray.append(user)
                                    //                                self.featuredArray.shuffle()
                                }
                        }
                    }
                }
            }
        }
    
    
//    func createRestaurant() {
//
//        var list : [String] = ["IMG_4944.JPG","IMG_4946.JPG"]
//
////        let list = ["IMG_3806.JPG","IMG_3807.JPG","IMG_3809.JPG","IMG_3810.JPG","IMG_3811.JPG","IMG_3812.JPG","IMG_3813.JPG","IMG_3816.JPG","IMG_3819.JPG","IMG_3820.JPG","IMG_3821.JPG","IMG_3823.JPG","IMG_3824.PNG","IMG_3825.JPG","IMG_3826.JPG","IMG_3827.JPG","IMG_3828.JPG","IMG_3832.JPG","IMG_3833.JPG","IMG_3835.JPG","IMG_3836.JPG","IMG_3837.JPG","IMG_3838.JPG","IMG_3839.JPG","IMG_3841.JPG","IMG_3842.WEBP","IMG_3843.WEBP","IMG_3844.WEBP","IMG_3845.WEBP","IMG_3847.WEBP","IMG_3848.WEBP","IMG_3849.WEBP","IMG_3853.JPG","IMG_3854.JPG","IMG_3855.JPG","IMG_3858.WEBP","IMG_3859.WEBP","IMG_3860.WEBP","IMG_3861.WEBP","IMG_3862.WEBP","IMG_3863.WEBP","IMG_3864.WEBP","IMG_3865.WEBP","IMG_3866.WEBP","IMG_3868.WEBP","IMG_3927.JPG","IMG_3928.JPG","IMG_3929.JPG","IMG_3930.JPG","IMG_3931.JPG","IMG_3932.JPG","IMG_3933.JPG","IMG_3934.JPG","IMG_3935.JPG","IMG_3936.JPG","IMG_3937.JPG","IMG_3938.JPG","IMG_3939.JPG","IMG_3940.JPG","IMG_3941.JPG","IMG_3942.JPG","IMG_3944.JPG","IMG_3945.JPG","IMG_3946.JPG","IMG_3947.JPG","IMG_3948.JPG","IMG_3949.JPG","IMG_3951.JPG","IMG_3952.JPG","IMG_3953.JPG","IMG_3954.JPG","IMG_3958.JPG","IMG_3959.JPG","IMG_3960.JPG","IMG_3961.JPG","IMG_3962.JPG","IMG_3963.JPG","IMG_3964.JPG","IMG_3964.png","IMG_3965.JPG","IMG_3966.JPG","IMG_3967.JPG","IMG_3968.JPG","abstract.JPG","airbaloones.JPG","beach.JPG","blackWave.JPG","building.JPG","buildsings.JPG","city.JPG","cityday.JPG","citylights.JPG","cityoftoronto.JPG","citysteeet.JPG","cityview.JPG","cliunds.JPG","cloudsmoon.JPG","cnNight.JPG","cnhigher.JPG","cntower.JPG","cnview.JPG","dersst.JPG","flats.JPG","flowerPot.JPG","forestguy.JPG","foresty.JPG","gradient.JPG","graydersert.JPG","greentrees.JPG","highways.JPG","iflltiwer.JPG","leafes.JPG","leaves.JPG","leavesblack.JPG","leaveslots.JPG","lotsoftrees.JPG","middlebuilding.JPG","moon.JPG","mountain.JPG","mountaincolor.JPG","mountainswater.JPG","newyork.JPG","newyorknightlight.JPG","onewayroad.JPG","onewayview.JPG","paliment.JPG","palmbay.JPG","palmcolor.JPG","palmfam.JPG","palmgradient.JPG","palmsky.JPG","palmtree.JPG","palmtrees.JPG","palmtreess.JPG","pinkfloewrs.JPG","pinkleafes.JPG","plainMountain.JPG","posche.JPG","road.JPG","roads.JPG","rocks.JPG","sea.JPG","skybuildings.JPG","skymoon.JPG","stechu.JPG","streetlight.JPG","thineleaves.JPG","timesquare.JPG","tokeyo.JPG","toronto.JPG","torontoice.JPG","torontolove.JPG","torontowater.JPG","tree.JPG","watermountain.JPG","wetforest.JPG","whiteclouds.JPG","whitepalm.JPG","wild.JPG"]
//
//
//        let db = Firestore.firestore()
//
//
//        print("printing 1")
//
//        for i in 0..<list.count {
//
//            let docRef = db.collection("Wallpapers").document(list[i])
//
//            print("printing 2")
//
//            let storage = Storage.storage().reference(withPath: "Wallpapers/\(list[i])")
//            storage.downloadURL { (url, error) in
//
//                print("printing 3")
//
//                if error != nil { print("cant get image",(error?.localizedDescription)!); return }
//
//                print("printing 4")
//
//                let consolidatedBucket = [
//                          "image": "\(url!)",
//                          "name": list[i],
//                          "categories": ["All"],
//                      ] as [String : Any]
//
//
//                docRef.setData(consolidatedBucket) { error in
//                    if let error = error {
//                        print("Error writing document: \(error)")
//                    } else {
//                        print("Document successfully written!")
//                    }
//                }
//
//
//                print("print 3", url!)
//
//            }
//
//        }
//    }
    
    
    
    
    

    
}

struct Class: Identifiable {
    var id = UUID()
    var name = ""
    var students: [Student] = [Student()]
}

struct Student: Identifiable {
    var id = UUID()
    var name: String = ""
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

public struct RefreshableScrollView<Content: View>: View {
    var content: Content
    var onRefresh: () -> Void

    public init(content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }

    public var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            onRefresh()
        }
    }
}

public extension Color {
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)

    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)

    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // There are more..
}



struct GrayButtonStyle: ButtonStyle {
    let w: CGFloat
    let h: CGFloat
    
    init(w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .frame(width: w, height: h)
            .padding(5)
            .background(Color(UIColor.white).opacity(0.35))
//            .overlay(Rectangle().strokeBorder(Color.green, lineWidth: 0))
//            .cornerRadius(20)
            .clipShape(Circle())
    }
}


extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}



extension Collection{
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool) -> [Element] {
        sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }
}


extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}



extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    func resize(_ width: CGFloat, _ height:CGFloat) -> UIImage? {
        let widthRatio  = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension String{
func replace(_ dictionary: [String: String]) -> String{
  var result = String()
  var i = -1
  for (of , with): (String, String)in dictionary{
      i += 1
      if i<1{
          result = self.replacingOccurrences(of: of, with: with)
      }else{
          result = result.replacingOccurrences(of: of, with: with)
      }
  }
return result
}
}




struct CoverData: Identifiable {
    let id = UUID()
//     var n: Int

    var imageName : String
    var imagelink : URL
    var depthimagelink : URL
}


extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}
