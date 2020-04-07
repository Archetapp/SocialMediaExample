//
//  RealmData.swift
//  SocialMediaApp
//
//  Created by Jared on 4/3/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift

class Profile : Object {
     @objc dynamic var username : String? = nil
     @objc dynamic var imageURL : String? = nil
     @objc dynamic var uid : String? = nil
     @objc dynamic var fullName: String? = nil
     @objc dynamic var userDescription : String? = nil
     var followerCount = RealmOptional<Int>()
     var followingCount = RealmOptional<Int>()
     var follower = RealmOptional<Bool>()
     var following = RealmOptional<Bool>()
    override static func primaryKey() -> String? {
         return "uid"
     }
}


class Post : Object {
    @objc dynamic var smallImage : String? = nil
    @objc dynamic var mediumImage : String? = nil
    @objc dynamic var largeImage : String? = nil
    @objc dynamic var fullImage : String? = nil
    @objc dynamic var message : String? = nil
    @objc dynamic var shareURL : String? = nil
    @objc dynamic var postID : String? = nil
    @objc dynamic var date : Date? = nil
    @objc dynamic var profile : Profile? = nil
    @objc dynamic var collection : String? = nil
    var liked = RealmOptional<Bool>()
    var numOfLike = RealmOptional<Int>()
    var numOfComments = RealmOptional<Int>()
    var numOfProducts = RealmOptional<Int>()
    var height = RealmOptional<Float>()
    var width = RealmOptional<Float>()
    
    //For Testing
    
    
    @objc dynamic var username : String? = nil
    
    override static func primaryKey() -> String? {
        return "postID"
    }
}


func checkIfProfileExists(_ uid : String) -> Profile? {
    return uiRealm.object(ofType: Profile.self, forPrimaryKey: uid)
}
extension Profile {
    func writeToRealm() {
        if checkIfProfileExists(self.uid!) != nil {
            return
        } else {
            try! uiRealm.write({
                () -> Void in
                uiRealm.add(self, update: .all)
            })
        }
    }
    func checkIfExists() -> Profile? {
        if uiRealm.object(ofType: Post.self, forPrimaryKey: self.uid) == nil {
            return self
        } else {
            return uiRealm.object(ofType: Profile.self, forPrimaryKey: self.uid)
        }
    }
    
}

func loadDataFromPostID(PostID : String, completion : @escaping (_ post : Post?) -> ()) {
    let databaseRef = Database.database().reference()
    databaseRef.child("Posts").child(PostID).observeSingleEvent(of: .value, with: {
        snapshot in
        if snapshot.exists() {
            handlePostData(snapshot: snapshot, completion: {
                finalStruct in
                if finalStruct != nil {
                    finalStruct?.writeToRealm()

                } else {
                    completion(nil)
                }
            })
        } else {
            completion (nil)
        }
    })
}

func postExistsCheck(_ postID : String) -> Post? {
    return uiRealm.object(ofType: Post.self, forPrimaryKey: postID)
}


extension Post {
    func writeToRealm() {
        if postExistsCheck(self.postID ?? "") != nil {
            return
        }
        try! uiRealm.write({
            () -> Void in
            uiRealm.add(self, update: .all)
        })
    }
    func checkIfPostExists() -> Post? {
        if uiRealm.object(ofType: Post.self, forPrimaryKey: self.postID) == nil {
            return self
        } else {
            return uiRealm.object(ofType: Post.self, forPrimaryKey: self.postID)
        }
    }
}

extension Date {
    //Format date to work with Amazon & Firebase
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601 : Date {
        return Date.Formatter.iso8601.date(from: self)!
    }
    
    func removeSpecialCharsFromString() -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),:!_")
        return String(self.filter {okayChars.contains($0) })
    }
}

func handlePostData(snapshot : DataSnapshot, completion : @escaping (_ post : Post?) -> ()) {
    if snapshot.exists() {
        let newPost = Post()
        let postID = snapshot.key
        let postUserID = (snapshot.value as! NSDictionary)["uid"] as! String
        let databaseRef = Database.database().reference()
        
        let largeImageURL = (snapshot.value as! NSDictionary)["largeImageURL"] as! String?
        let smallImageURL = (snapshot.value as! NSDictionary)["smallImageURL"] as! String?
        let mediumImageURL = (snapshot.value as! NSDictionary)["mediumImageURL"] as! String?
        let fullImageURL = (snapshot.value as! NSDictionary)["fullImageURL"] as! String?

        print(snapshot)
        let message = (snapshot.value as! NSDictionary)["bodyText"] as! String?
        
        let shareURL = (snapshot.value as! NSDictionary)["link"]
        let collection = (snapshot.value as! NSDictionary)["collection"] as! String?
        
        //Handle Likes
        let numOfLikes = (snapshot.value as! NSDictionary)["likes"] as? Int
        let numOfComments = (snapshot.value as! NSDictionary)["comments"] as? Int

        databaseRef.child("likes").child(postID).child(mainUser?.uid ?? "").observeSingleEvent(of: .value) { (likeSnapshot) in
            try! uiRealm.write {
                if likeSnapshot.exists() {
                    newPost.liked.value = true
                } else {
                    newPost.liked.value = false
                }
            }
        }
        
        let stringFromDate =  (snapshot.value as! NSDictionary) ["date"] as! String
        let dateFinal = stringFromDate.dateFromISO8601
        loadUser(postUserID) { (Profile) in
            if let Profile = Profile {
                print(Profile)
                
                newPost.smallImage = smallImageURL
                newPost.largeImage = largeImageURL
                newPost.mediumImage = mediumImageURL
                newPost.fullImage = fullImageURL
                newPost.message = message
                newPost.numOfLike.value = numOfLikes
                newPost.numOfComments.value = numOfComments
                newPost.shareURL = shareURL as? String
                newPost.postID = postID
                newPost.date = dateFinal
                newPost.profile = Profile
                newPost.collection = collection
                newPost.writeToRealm()
                completion(newPost)
            }
        }
    }
}

//Checks if a user exists based on UID
func checkIfUserExists(userID : String, completion: @escaping (_ success: Bool) -> ()){
    var userBool = Bool()
    let usersRef = Database.database().reference()
    if userID != "" {
        print(userID)
        usersRef.child("users").child(userID).observeSingleEvent(of: .value, with:{
            snapshot in
            if snapshot.hasChild("name") == true {
                userBool = true
            }
            else {
                userBool = false
            }
            completion(userBool)
        })
    } else {
        completion(false)
    }
}

func loadUser(_ uid : String, completion : @escaping (_ user : Profile?) -> ()) {
    checkIfUserExists(userID: uid.removeSpecialCharsFromString()) { (exists) in
        if exists == false {
            completion(uiRealm.object(ofType: Profile.self, forPrimaryKey: uid))
        } else {
            DispatchQueue.main.async {
                let database = Database.database().reference()
                print(uid)
                database.child("users").child(uid.removeSpecialCharsFromString()).observeSingleEvent(of: .value, with: {
                    snapshot in
                    if snapshot.exists() {
                        guard let dictionary = snapshot.value as? NSDictionary else { return }
                        let profileImage = dictionary["profileImage"] as? String? ?? ""
                        let username = dictionary["name"] as? String? ?? ""
                        let fullName = dictionary["nameFull"] as? String? ?? ""
                        let description = dictionary["description"] as? String? ?? ""
                        let followerCount = dictionary["followersCount"] as? Int ?? 0
                        let followingCount = dictionary["followingCount"] as? Int ?? 0
                        
                        
//                        var following = Bool()
//                        var follower = Bool()
//
//                        if mainUser?.following.contains(uid) {
//                            following = true
//                        } else {
//                            following = false
//                        }
//
//                        if mainUser.followers.contains(uid) {
//                            follower = true
//                        } else {
//                            follower = false
//                        }
                        
                        let person = Profile()
                        person.username = username
                        person.imageURL = profileImage
                        person.fullName = fullName
                        person.uid = uid
                        person.userDescription = description
                        person.followerCount.value = followerCount
                        person.followingCount.value = followingCount
                        person.writeToRealm()
                        
                        completion(person)
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }
}
