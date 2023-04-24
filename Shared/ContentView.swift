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


struct ContentView: View {
    
    
    @State private var selection: Tab = .featured

    
    enum Tab {
        case featured
        case category
        case list
    }
    
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    @State var list: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            LoadContentView().tabItem { Label("Home", systemImage: "star") }.tag(Tab.featured)
            CategoryView().tabItem { Label("Explore", systemImage: "sparkle.magnifyingglass") }.tag(Tab.category)
            More().tabItem { Label("More", systemImage: "list.bullet") }.tag(Tab.list)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirestoreManager())
    }
}
