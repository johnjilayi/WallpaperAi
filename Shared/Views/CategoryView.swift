//
//  CategoryView.swift
//  Shared
//
//  Created by Jonathan Njilay on 2022-05-24.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseStorage
import Kingfisher
import Foundation
import Vision


struct CategoryView: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State var catImages = ["",""]
    @State private var showSheet = false
    let userDefaults = UserDefaults.standard
    @State private var myFavs : [String : String] = [:]
    
    
    @ObservedObject var viewModel = ListViewModel()
    
    
    @State var showRewardedAd: Bool = false
    @State var showIntersitialAd: Bool = false
    @State var rewardGranted: Bool = false
    
    @State var imageLink = URL(string:"https://firebasestorage.googleapis.com:443/v0/b/walls-88b92.appspot.com/o/Wallpapers%2FIMG_3809.JPG?alt=media&token=9520f598-19a2-4507-837e-8c6a7729ac51")

    @State var detectedPerson1: [Int:UIImage?] = [:]
    @State var detectedPerson2: [Int:UIImage?] = [:]
    
    @State var coverData: CoverData?

    var body: some View {

        NavigationView {
            
            GeometryReader{ bounds in
                
            ScrollView(.vertical, showsIndicators: false) {

                
                PullToRefreshView { setUrls() }
                                
//                if myFavs.isEmpty { BannerView().padding(.bottom, 60).padding(.top, 0) } else { BannerView().padding(.bottom, 60).padding(.top, 0) }

                loadFavView()
                
                loadImages(for: bounds)
                            
//                BannerView().padding(.bottom, 60 + (UIDevice.isIPhone ? 0 :  30)).padding(.top, 0)

                Text("Categories").font(.headline).foregroundColor(Color.primary)
                    .padding(.leading, 15)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                loadList()
                

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .listStyle(InsetListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {UITableView.appearance().separatorStyle = .none}
            .navigationBarItems(leading: HStack { Text("Discovery").font(.title).fontWeight(.heavy) }.offset(x:-3))
            
        }
            
            .onAppear(){ setUrls() }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())

        .navigationViewStyle(.stack)
            

    }
    
    func didDismiss() { coverData = nil }

    func loadScreensPush(for image: String, bounds : GeometryProxy) -> some View {
                Image(image)
                    .resizable()
                    .animation(.easeInOut(duration: 2), value: 1.0)
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
    }
    
    func loadFavView() -> some View {
        
        NavigationLink(destination: imageList(catList: [], showFav: true)){
            HStack {Text("Favourites").font(.headline).foregroundColor(Color.primary)
                    .padding(.leading, 15).padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("View all >").font(.system(size: 12)).frame(alignment: .trailing).foregroundColor(.gray).padding()
            }}
        
    }
    
    
    func setUrls() { //print("setting")
        myFavs = userDefaults.object(forKey: "myFav") as? [String:String] ?? [:]
        print("setting", myFavs.count)
    }
    
    func loadImages(for bounds: GeometryProxy) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                
                if myFavs.isEmpty {
                    ZStack {
                        Image("LaunchScreen").resizable().scaledToFill()
                            .frame(width: UIScreen.screenWidth-20, height: 100, alignment: .center)
                            .overlay(Rectangle()
                                .foregroundColor(.clear)
                                .background(LinearGradient( gradient: Gradient(colors: [.black.opacity(0.6), .white.opacity(0.2)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                .frame(width: UIScreen.screenWidth-20, height: 100))
                        
                        VStack {
                            Text("No Favourites").font(.largeTitle)
                            Text("Pull To Reload").font(.footnote)
                        }.foregroundColor(.white)
                    }.cornerRadius(15)
                    
                } else { ForEach(Array(myFavs.enumerated()), id: \.0) { index, itemss in

                        ZStack {
                            let url = URL(string: itemss.key)
                            let depthurl = URL(string: itemss.value)
                            let name = itemss.key
                            Button(action: { coverData = CoverData(imageName: name, imagelink: url!, depthimagelink: depthurl!) }) {
                                
                                getListImage(for: URL(string: itemss.key), Depthurl: URL(string: itemss.value), bounds : bounds).padding(.leading, 5)

                                
                            } .fullScreenCover(item: $coverData, onDismiss: didDismiss) { details in
                                imageView(urlString: details.imagelink, depthString: details.depthimagelink, imageName: details.imageName)
                                 }
                        }
                    }
                }
            }.padding(10)

            
        }.onAppear() {        }
        
    }
    
    
    func loadList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(0..<firestoreManager.catNames.count, id: \.self) { items in
                ZStack(alignment: .bottomLeading) {
                    
                    NavigationLink(destination: imageList(catList: [firestoreManager.catNames[items]])){
                        Image(firestoreManager.catNames[items]).resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.screenWidth-20, height: UIScreen.screenWidth*0.3, alignment: .center)
                            .overlay(Rectangle()
                                .foregroundColor(.clear)
                                .background(LinearGradient( gradient: Gradient(colors: [.black.opacity(0.87), .white.opacity(0.2)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                .frame(width: UIScreen.screenWidth-20, height: UIScreen.screenWidth*0.3))
                            .cornerRadius(15)
                        
                    }
                    Text(firestoreManager.catNames[items]).font(.largeTitle).fontWeight(.heavy)
                        .foregroundColor(.white).padding(20).foregroundColor(.white).offset(x: 5, y: 5)
                }
            }
            
        }
    }
    
    func getListImage(for url: URL?, Depthurl: URL?, bounds : GeometryProxy) -> some View {
        
        ZStack {
            
            KFImage.url(url)
                .placeholder { progress in
                    ProgressView()
                }
                .resizable()
                .onSuccess { result in }
                .loadDiskFileSynchronously()
                .fade(duration: 2.25)
                .onProgress { receivedSize, totalSize in }
                .onFailure { error in }
                .cancelOnDisappear(false)
                .scaledToFill()
                .frame(width: bounds.size.width*0.42, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.42, alignment: .center).cornerRadius(15).clipped()

                .overlay() {
                    
                    if Depthurl == url {} else {
                        ZStack {
                            if !UIDevice.isIPhone {} else {
                                loadScreensPush(for: UIDevice.isIPhone ? "IOS16LOOCKSCREENX1" : "IOS16LOOCKSCREENX4", bounds: bounds)
                                KFImage.url(Depthurl)
                                    .placeholder { progress in
                                        ProgressView()
                                    }
                                    .resizable()
                                    .onSuccess { result in }
                                    .loadDiskFileSynchronously()
                                    .fade(duration: 2.25)
                                    .onProgress { receivedSize, totalSize in }
                                    .onFailure { error in }
                                    .cancelOnDisappear(false)
                                    .scaledToFill()
                                    .frame(width: bounds.size.width*0.42, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.42, alignment: .center).cornerRadius(15).clipped()
                                
                            }}}}
            
            
        }
        
    }
    
    
    
    
    func getListImagez(for url: URL!, bounds: GeometryProxy) -> some View {
        
        
        KFImage.url(url)
            .placeholder { ZStack { Color(.clear)
                    Text("Loading..").foregroundColor(.accentColor)}}
            .resizable()
            .loadDiskFileSynchronously()
            .fade(duration: 1.25)
            .onProgress { receivedSize, totalSize in }
            .onSuccess { result in  }
            .onFailure { error in }
            .cancelOnDisappear(false)
            .scaledToFill()
            .frame(width: bounds.size.width*0.42, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.42, alignment: .center).cornerRadius(15).clipped()
    }
    
    
    func runCode() {print("print movie 2", firestoreManager.dataArray.count) }
    
    
    func getListImageDepth(for url: URL?, item : Int, loc : Int, isImageLoaded: Bool, viewsType: Bool, bounds : GeometryProxy) -> some View {
        
        ZStack() {
            KFImage.url(url)
                .resizable()
                .placeholder { ZStack { Color(.clear)
                       Text("Loading...").foregroundColor(.accentColor)}}
                .onSuccess { result in
                    print("print thuis images are", loc, result.image.description)
                    segmetPersonOnImage(segmetImage: result.image, item: item, loc: loc, viewsType: viewsType)}
                .loadDiskFileSynchronously()
                .fade(duration: 2.25)
                .onFailure { error in }
                .cancelOnDisappear(false)
                .scaledToFill()
                .onAppear(){print("print thuis onappeare", item)}
                .overlay {
                    if viewsType {
                        if detectedPerson1.count > 0  {
                            if let detectedPersons = detectedPerson1[item] {
                                TimeView()
                                //MARK: Placing over the normal image
                                Image(uiImage: detectedPersons!).resizable().aspectRatio(contentMode: .fill).clipped()
                            }} else { /*let _ =  print("print thuis Empty2", item)*/ }
                    } else {
                        if detectedPerson2.count > 0  {
                            if let detectedPersons = detectedPerson2[item] {

                                TimeView()
                                //MARK: Placing over the normal image
                                Image(uiImage: detectedPersons!).resizable().aspectRatio(contentMode: .fill).clipped()
                            }} else { /*let _ =  print("print thuis Empty2", item)*/ }
                    }
                }
        }
        .frame(width: bounds.size.width*0.42, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.42, alignment: .center).cornerRadius(15).clipped()
    }
    
    
    //MARK: Person Segmentation Using Vision
    func segmetPersonOnImage(segmetImage: UIImage, item : Int, loc : Int, viewsType: Bool) {
                
        guard let image = segmetImage.cgImage else{
            print("no compressed image")
            return}
        
        
        //MARK: Request
        let request = VNGeneratePersonSegmentationRequest()
        //MARK: Set this to true only for Testing in Simulator
        
        
        //MARK: task Handler
        let task = VNImageRequestHandler(cgImage: image)
        
        try? task.perform([request])
        
        
        //            MARK: Result
        let result = request.results?.first
        let buffer = result!.pixelBuffer
        maskWithOriginalImage(buffer: buffer, item: item , loc: loc, imageWidth: segmetImage.size.width, imageHieght: segmetImage.size.height, segmetImage: segmetImage, viewsType: viewsType)
    }
    
    
    
    //MARK: it will give the mask/outline of the person present in the image
    //we need to mask it with the original image, in order to remove the background
    
    func maskWithOriginalImage(buffer: CVPixelBuffer, item: Int, loc : Int, imageWidth : CGFloat, imageHieght: CGFloat, segmetImage: UIImage, viewsType: Bool){
        let user = postClass()

        //         let images = segmetImage.ciImage!
        let cgImage = segmetImage.cgImage!
        
        let original = CIImage(cgImage: cgImage)
        let mask = CIImage(cvImageBuffer: buffer)
        
        //MARK: Scaling Properties of the masl in order to fit perfectly
        let maskX = original.extent.width / mask.extent.width
        let maskY = original.extent.height / mask.extent.height
        
        let resizedMask = mask.transformed(by: CGAffineTransform(scaleX: maskX, y: maskY))
        
        //MARK: Filter using core image
        let filter = CIFilter.blendWithMask()
        filter.inputImage = original
        filter.maskImage = resizedMask
        
        
        let maskedImage = filter.outputImage
        
        
        //MARK: Creating uiimage
        let context = CIContext()
        let image = context.createCGImage(maskedImage!, from: maskedImage!.extent)
        
        //This is detected Person image
        let Person = UIImage(cgImage: image!)
        
        if viewsType { detectedPerson1[item] = Person } else { detectedPerson2[item] = Person
            
            user.item = item
            user.loc = loc
            user.images[item] =  Person
            
            print("print thuis detectedPerson3",item)

        }
    }
}


struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .environmentObject(FirestoreManager())
    }
}





class ListViewModel: ObservableObject {
    
    let userDefaults = UserDefaults.standard.object(forKey: "myFav") as? [String] ?? []
    @State var myFavs = UserDefaults.standard.object(forKey: "myFav") as? [String] ?? []
    
    @Published var items = ["item1", "item2", "item3", "item4", "item5","item6"]
    
    func addItem(){
        items.append("item7")
    }
}
