//
//  TabViewController.swift
//  SocialMediaApp
//
//  Created by Jared on 4/3/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import Foundation
import SwiftUI

struct tabViewController : View {
    @State var isPresented : Bool = false
    @State var selectedTab = 0
    var body : some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem{
                    Text("Home")
                }.tag(0)
            ExploreView()
                .tabItem({
                    Text("Explore")
                }).tag(1)
            RandomView()
                .tabItem({
                    Text("Create").onTapGesture {
                        self.isPresented = true
                    }
                }).tag(2)
            NotificationView()
                .tabItem({
                    Text("Notification")
                }).tag(3)
            ProfileView()
                .tabItem({
                    Text("Explore")
                }).tag(4)
        }.sheet(isPresented: $isPresented, content: {CreatePostView()})
    }
}

struct TabViewController_Previews: PreviewProvider {
    static var previews: some View {
        tabViewController()
    }
}
