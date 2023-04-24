//
//  ContentView.swift
//  Shared
//
//  Created by Jonathan Njilay on 2022-05-24.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseStorage
import Kingfisher
import GoogleMobileAds
import Vision

struct LoadContentView: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    var adViewControllerRepresentableView: some View {
        firestoreManager.adViewControllerRepresentable
        .frame(width: .zero, height: .zero)
    }
    
    @State var selectedImage: Image = Image("logo")
    @State var placeholderImage: Image = Image("LaunchScreen")
    @State var list: Int = 0
    @State private var showSheet = false
    @State private var showSheet2 = false
    @State var images = Image("logo")
    @State private var pressed = false

    
    @State var showRewardedAd: Bool = false
    @State var showIntersitialAd: Bool = false
    @State var rewardGranted: Bool = false
    @State var imageLink = URL(string:"https://firebasestorage.googleapis.com/v0/b/walls-88b92.appspot.com/o/Wallpapers%2FIMG_3806.JPG?alt=media&token=4b1edd6a-6bf9-4720-b608-ad1878dccc84")

    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
        
    @State var detectedPerson1: [Int:UIImage?] = [:]
    @State var detectedPerson2: [Int:UIImage?] = [:]

    var scale: CGFloat = 1
    var lastScale : CGFloat = 0
    
    var textRect: CGRect = .zero
    
    @State var getInageLists1: [String] = []
    
    @State var coverData: CoverData?

    
    var body: some View {

        NavigationView {
            
            GeometryReader{ bounds in
            ScrollView(.vertical) {
                

                Text("Featured").font(.title)  // .font(.headline)
                    .padding(.leading, 15).padding(.top, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        
                        ForEach(0..<firestoreManager.featuredArray.count, id: \.self) { items in
                            ZStack {
                                let url = URL(string: firestoreManager.featuredArray[items].imageUrl)
                                let depthurl = URL(string: firestoreManager.featuredArray[items].DepthimageUrl)
                                let name = firestoreManager.featuredArray[items].name
                                Button(action: {
                                    
                                    coverData = CoverData(imageName: name, imagelink: url!, depthimagelink: depthurl!)
                                }) {
                                    
                                    getListImageTop(for: url, Depthurl: depthurl, bounds : bounds).padding(.leading, 5)

                                }.fullScreenCover(item: $coverData, onDismiss: didDismiss) { details in
                                    imageView(urlString: details.imagelink, depthString: details.depthimagelink, imageName: details.imageName)
                                     }
                            }
                        } 
                    }.padding(5)
                }
                 
                loadBottomView(for: bounds)
            }

            .frame(maxWidth: .infinity, alignment: .leading)
            .listStyle(InsetListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {UITableView.appearance().separatorStyle = .none}
            .navigationBarItems(leading: HStack { Text("Wallpaper Ai").font(.title).fontWeight(.heavy) }.offset(x:-3))
            .background(adViewControllerRepresentableView)

            }
        .onAppear(){ firestoreManager.newcoordinator.LoadInterstitial() }
            
        
    }
        
        
    .edgesIgnoringSafeArea(.all)
    .navigationViewStyle(.stack)
    }

    
    func didDismiss() { coverData = nil }

    
    func loadScreensPush(for image: String, bounds : GeometryProxy) -> some View {
            Image(image)
                .resizable()
                .animation(.easeInOut(duration: 2), value: 1.0)
                .scaledToFill()
    }
    
    
    func loadBottomView(for bounds: GeometryProxy) -> some View {
        
        VStack {

            ForEach(0..<firestoreManager.dataArray.count, id: \.self) { items in
                
                
                NavigationLink(destination: imageList(catList: [firestoreManager.dataArray[items].category])){
                    
                    HStack {
                        Text(firestoreManager.dataArray[items].category).font(.headline).foregroundColor(Color("TextColor"))
                            .padding(.leading, 15)//.padding(.top, 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("View all >").font(.system(size: 12)).frame(alignment: .trailing).foregroundColor(.gray).padding()//.padding(.top, 15)
                    }
                    
                }
                
                
                ScrollView(.horizontal) {

                    HStack {

                            ForEach(Array(firestoreManager.dataArray[items].children2.enumerated()), id: \.0) { index, item in

                            ZStack {
                                let url = URL(string: item.key)
                                let depthurl = URL(string: item.value)
                                let name = firestoreManager.dataArray[items].name

                                Button(action: {  coverData = CoverData(imageName: name, imagelink: url!, depthimagelink: depthurl!) }) {
                                    
                                    getListImage(for: URL(string: item.key), Depthurl: URL(string: item.value), bounds : bounds).padding(.leading, 5)

                                    } .fullScreenCover(item: $coverData, onDismiss: didDismiss) { details in
                                        imageView(urlString: details.imagelink, depthString: details.depthimagelink, imageName: details.imageName)
                                         }
                            }
                        }
                    }.padding(5)
                }
            
            }
            
        }
        
    }
    
    func getListImageTop(for url: URL?, Depthurl: URL?, bounds : GeometryProxy) -> some View {
        
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
                .frame(width: bounds.size.width*0.52, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.52, alignment: .center).cornerRadius(15)//.clipped()

                .overlay() {
                    
                    if Depthurl == url {} else {

                            if !UIDevice.isIPhone {} else {
                                if !UIDevice.current.hasNotch {} else {
                            loadScreensPush(for: "IOS16LOOCKSCREENX1", bounds: bounds)
                                .edgesIgnoringSafeArea(.all)
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
                                .frame(width: bounds.size.width*0.52, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.52, alignment: .center).cornerRadius(15)//.clipped()

                                
                            }
                            
                        }
                        
                    }}
            
            
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
            
                .frame(width: bounds.size.width*0.4, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.4, alignment: .center).cornerRadius(15).clipped()

                .overlay() {
                    
                    if Depthurl == url {} else {
                        ZStack {
                            if !UIDevice.current.hasNotch {} else {

                                if !UIDevice.isIPhone {} else {
                                    loadScreensPush(for: "IOS16LOOCKSCREENX1", bounds: bounds)
                                        .edgesIgnoringSafeArea(.all)
                                    
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
                                    //                    .scaleEffect(0.3)
                                        .frame(width: bounds.size.width*0.4, height: (bounds.size.height+bounds.safeAreaInsets.top+bounds.safeAreaInsets.bottom)*0.4, alignment: .center).cornerRadius(15).clipped()
                                    
                                }}}}}
            
            
        }
        
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
        
        let Person = UIImage(cgImage: image!)
        
        if viewsType { detectedPerson1[item] = Person } else { detectedPerson2[item] = Person
            
            user.item = item
            user.loc = loc
            user.images[item] =  Person
            
        }

        
    }
    
    
}


struct LoadContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadContentView()
            .environmentObject(FirestoreManager())
    }
}
