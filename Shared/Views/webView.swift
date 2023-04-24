

//
//  WKWebViewController.swift
//  fooBasic
//
//  Created by Mark Hunte on 03/09/2019.
//  Copyright © 2019 Mark Hunte. All rights reserved.
//

import UIKit
import WebKit
import SwiftUI



struct Termsandconditions: UIViewRepresentable {
   
   
    func makeUIView(context: Context) -> WKWebView {
           let wconfiguration = WKWebViewConfiguration()
                  
                  //-- false = Play video with native device player ; true =  inline
                  wconfiguration.allowsInlineMediaPlayback = false
                  
                  //-- Does not require user inter action for .ie sound auto playback
                  wconfiguration.mediaTypesRequiringUserActionForPlayback = []
                  
                  let webView =  WKWebView(frame: .zero, configuration: wconfiguration)
                  
                  let  theFileName = ("Termsandconditions" as NSString).lastPathComponent
                  let htmlPath = Bundle.main.path(forResource: theFileName, ofType: "html")
                  
                  let folderPath = Bundle.main.bundlePath
                  
                  let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
                  
                  do {
                      
                      let htmlString = try NSString(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8.rawValue)
                      
                      webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
                      
                  } catch {
                
                  }
                  return    webView
                         
                     }
       
       
       func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<Termsandconditions>) {
        
       }
    
     
}




struct Privacypolicy: UIViewRepresentable {
   
    func makeUIView(context: Context) -> WKWebView {
           let wconfiguration = WKWebViewConfiguration()
                  
                  //-- false = Play video with native device player ; true =  inline
                  wconfiguration.allowsInlineMediaPlayback = false
                  
                  //-- Does not require user inter action for .ie sound auto playback
                  wconfiguration.mediaTypesRequiringUserActionForPlayback = []
                  
                  let webView =  WKWebView(frame: .zero, configuration: wconfiguration)
                  
                  let  theFileName = ("Privacypolicy" as NSString).lastPathComponent
                  let htmlPath = Bundle.main.path(forResource: theFileName, ofType: "html")
                  
                  let folderPath = Bundle.main.bundlePath
                  
                  let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
                  
                  do {
                      
                      let htmlString = try NSString(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8.rawValue)
                      
                      webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
                      
                  } catch {            }
           
    
                  return webView
                         
                     }
       
       
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<Privacypolicy>) {

    }
     
}
