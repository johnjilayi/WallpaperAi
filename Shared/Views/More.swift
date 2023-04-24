//
//  More.swift
//  WallsAi
//
//  Created by Jonathan Njilay on 2022-07-25.
//

import SwiftUI
import StoreKit


struct More: View {
    
    var body: some View {
        
        NavigationView {
            List() {
                
                VStack {
                    
                    Image("logo").resizable()
                        .scaledToFit()
                        .background(Color.black.opacity(0.2))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40, alignment: .leading)
                        .cornerRadius(10)
                        .padding()
                    
                    Text("Wallpaper Ai")
                        .font(.title)
                        .fontWeight(.heavy)
                        .font(.headline)
                        .padding()
                    Text("Thank You.")
                        .padding(.top, 5)
                    
                    Text("")
                        .padding(0)
                        .multilineTextAlignment(.center)
                        .lineLimit(10)
                    
                }.frame(maxWidth: .infinity, maxHeight: 700, alignment: .center)
                
                
                Button(action: {
                    let mailTo = "mailto:johnjilayi@gmail.com?subject=Wallpaper Ai feedback&body=Hello I have an feedback...".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let mailtoUrl = URL(string: mailTo!)!
                    if UIApplication.shared.canOpenURL(mailtoUrl) { UIApplication.shared.open(mailtoUrl, options: [:]) }
                }){
                    HStack {
                        Image(systemName: "message.fill").resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30, alignment: .leading).padding()
                        Text("Feedback & Suggestions").foregroundColor(Color("TextColor"))
                    }}.frame(height: 60, alignment: .leading)
                
                
                HStack {
                    NavigationLink(destination: Termsandconditions()){
                        Image(systemName: "questionmark.circle.fill").resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30, alignment: .leading).padding()
                        Text("Terms & Conditions")
                    }}.frame(height: 60, alignment: .leading)
                
                HStack {
                    NavigationLink(destination: Privacypolicy()){
                        Image(systemName: "exclamationmark.circle.fill").resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30, alignment: .leading).padding()
                        Text("Privacy Policy")
                    }}.frame(height: 60, alignment: .leading)
                
                
                Button(action: {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene { SKStoreReviewController.requestReview(in: scene) }
                }){
                    HStack {
                        Image(systemName: "heart.text.square.fill").resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30, alignment: .leading).padding()
                        Text("Write us a review").foregroundColor(Color("TextColor"))
                        
                    }}.frame(height: 60, alignment: .leading)
                
                VStack {
                    Text("These wallpapers are sorced from www.freepics.com")
                        .fontWeight(.ultraLight)
                        .padding(5)
                        .multilineTextAlignment(.center)
                        .lineLimit(10)
                }.frame(maxWidth: .infinity, maxHeight: 700, alignment: .center)
                
                Spacer()
                HStack {
                    Text("App Version").frame(height: 30, alignment: .leading)
                    Text("1.2.0").font(.system(size: 12)).frame(alignment: .trailing)
                }.frame(maxWidth: .infinity, maxHeight: 40).padding()                
            }
            
            .listStyle(InsetListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear { UITableView.appearance().separatorStyle = .none }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())

        .navigationViewStyle(.stack)
    }
}

struct More_Previews: PreviewProvider {
    static var previews: some View {
        More()
    }
}

