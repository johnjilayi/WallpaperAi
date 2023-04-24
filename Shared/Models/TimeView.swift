//
//  TimeView.swift
//  IOS16Lockscreen
//
//  Created by Jonathan Njilay on 2022-09-25.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import FirebaseStorage
import Kingfisher


struct TimeView: View {
    var body: some View {
        GeometryReader{ proxy in

        HStack(spacing: -1){


            let hour = String(Int(Date.now.convertToString(.hour))!)
            Text(hour).fontWeight(.bold)

            Text(":").fontWeight(.bold).padding(.bottom, 8)//.padding(.leading, 5).padding(.trailing, 5)

            Text(Date.now.convertToString(.minute)).fontWeight(.bold)

        }
        .font(.system(size:95*0.50))
        .foregroundColor(.white)
        .frame(maxWidth: proxy.size.width, alignment: .top)
        .padding(.top, proxy.size.height*0.14)

    }}
}

struct TimeViewMain: View {
    var body: some View {
        GeometryReader{ proxy in

        HStack(spacing: -1){
            let hour = String(Int(Date.now.convertToString(.hour))!)
            Text(hour).fontWeight(.bold)

            Text(":").fontWeight(.bold).padding(.bottom, 8)//.padding(.leading, 5).padding(.trailing, 5)

            Text(Date.now.convertToString(.minute)).fontWeight(.bold)
        }
//        .font(.system(size:95))
        .font(.system(size:proxy.size.width/2*0.39))
        .foregroundColor(.white)
//        .frame(maxWidth: proxy.size.width, alignment: .top)
        .frame(width: proxy.size.width, alignment: .top)
        .padding(.top, proxy.size.height*0.14)

    }}
}


enum DateFormat: String {
    case hour = "h"
    case minute = "mm"
    case seconds = "ss"
}

extension Date{
    func convertToString(_ format: DateFormat)-> String{
        let formater = DateFormatter()
        formater.dateFormat = format.rawValue
        return formater.string(from: self)
    }
}


//MARK: Rect Prefernece Key

struct RectKey: PreferenceKey{
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
