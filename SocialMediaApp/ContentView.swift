//
//  ContentView.swift
//  SocialMediaApp
//
//  Created by Jared on 4/2/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import SwiftUI
import UIKit
import FirebaseMLVision

struct ContentView: View {
    
    @ObservedObject var postStorage = PostStore()
    
    
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List(0 ..< 5) {_ in
                    PostView()
                }.padding(0)
            }.navigationBarTitle("Home").navigationBarItems(trailing: Button(action: {
                }, label: {
                    Image("MoreComment").renderingMode(.original)
                }).allowsHitTesting(false)
            )
        }
    }
    
    func LoadPosts() {
        
    }
}

class PostStore : ObservableObject {
    @Published var posts = [Post]()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PostView: View {
    @State var presented : Bool = false
    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    Image("Screen Shot 2020-04-01 at 2.42.18 PM")
                        .resizable().aspectRatio(contentMode: .fit)
                    HStack(alignment: .top) {
                        Text("Hey Guys, this is Jared, I just really wanted to say thanks for all the support, you guys are the best and I hope that  best for you and your family.").font(.footnote).fontWeight(.light).foregroundColor(Color.black).padding()
                        Spacer()
                        Text("21D").font(.caption).fontWeight(.light).multilineTextAlignment(.center).padding().frame(alignment: .topTrailing)
                    }
                    Divider()
                    Spacer()
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Image("MoreComment").renderingMode(.original)
                            }).padding().buttonStyle(PlainButtonStyle())
                        Spacer()
                        Button(action: {
                            self.presented.toggle()
                        }, label: {
                            Image("AddBtn").renderingMode(.original)
                        }).padding().buttonStyle(PlainButtonStyle())
                    }
                }.background(Color.white).cornerRadius(10)
            }.shadow(radius: 10).frame(alignment: .center).padding(10)
        }.sheet(isPresented: $presented, onDismiss: {self.presented = false}, content: {RandomView()})
    }
}

struct RandomView : View {
    var body : some View {
        VStack {
            Text("Hello")
        }
    }
}
