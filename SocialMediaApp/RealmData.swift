//
//  RealmData.swift
//  SocialMediaApp
//
//  Created by Jared on 4/3/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import Foundation
import RealmSwift

class Profile {
     @objc dynamic var username : String? = nil
     @objc dynamic var imageURL : String? = nil
     @objc dynamic var uid : String? = nil
     @objc dynamic var fullName: String? = nil
     @objc dynamic var userDescription : String? = nil
     var followerCount = RealmOptional<Int>()
     var followingCount = RealmOptional<Int>()
     var follower = RealmOptional<Bool>()
     var following = RealmOptional<Bool>()
     static func primaryKey() -> String? {
         return "uid"
     }
}

