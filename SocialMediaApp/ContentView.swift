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
import Firebase
import RealmSwift

class FeedFetcher : ObservableObject {
    @State var dataIsLoaded: Bool = false
    
    
    var documents: [DocumentSnapshot] = []
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("Posts").limit(to: 50)
    }
    
    fileprivate var query: Query?
    
    init() {
        self.query = baseQuery()
        self.LoadPosts(completion: { completed in
            self.dataIsLoaded.toggle()
        })
    }
    
    func LoadPosts(completion : @escaping(_ completion : Bool) -> ()) {
           print(uiRealm.objects(Post.self))
           query?.addSnapshotListener { (documents, error) in
               guard let snapshot = documents else {
                   print("Error fetching documents results: \(error!)")
                   return
               }
               for snap in snapshot.documents {
                   let imageURL = snap.data()["imageURL"] as? String
                   let description = snap.data()["description"] as? String
                   print(snap.data())
                   let height = snap.data()["height"] as? Float
                   let width = snap.data()["width"] as? Float
                   let user = snap.data()["user"] as? String
                   let id = snap.data()["id"] as? String

                   let post = Post()
                   post.postID = id
                   post.fullImage = imageURL
                   post.message = description
                   post.height.value = height
                   post.width.value = width
                   post.username = user
                   post.writeToRealm()
            }
            completion(true)
        }
    }
}

struct ContentView: View {
    @ObservedObject var feed = FeedFetcher()
    
    init() {
//        let allPostObjects = uiRealm.objects(Post.self)
//        try! uiRealm.write {
//            uiRealm.delete(allPostObjects)
//        }
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(uiRealm.objects(Post.self), id: \Post.self, content: { object in
                        PostView(post: object)
                    })
                }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }.navigationBarTitle("Home").navigationBarItems(trailing: Button(action: {
                }, label: {
                    Image("MoreComment").renderingMode(.original)
                }).allowsHitTesting(false)
            ).padding(0)
        }
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
    var aspectRatio = CGFloat()
    var currentPost = Post()
    init(post : Post) {
        print("width", UIScreen.main.bounds.width)
       currentPost = post
        guard let width = currentPost.width.value, let height = currentPost.height.value else { return }
        print(width, height)
        aspectRatio = CGFloat(height / width)
        print(aspectRatio)
    }
    
    @State var presented : Bool = false
    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    AsyncImage(url: URL(string: currentPost.fullImage ?? "")!, placeholder: Text("... Loading"), cache: TemporaryImageCache()).frame(height: aspectRatio * (UIScreen.main.bounds.width - 80), alignment: .top)
                    HStack(alignment: .top) {
                        Text(currentPost.message ?? "").font(.footnote).fontWeight(.light).foregroundColor(Color.black).padding()
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
            }.shadow(radius: 10).frame(alignment: .center)
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
