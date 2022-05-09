//
//  ATCRemoteData.swift
//  ChatApp
//
//  Created by Dan Burkhardt on 3/20/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Foundation
import Firebase
import UIKit

/// Sample class that gets all channels from the remote data store.
class ATCRemoteData{
    let db = Firestore.firestore()
    static var threads: [ATChatMessage] = []
    static var friends: [ATCUser] = []
    static var user: ATCUser = ATCUser()
    static var channelIds: [String] = []
    static var channels: [ATCChatChannel] = []
    
    func getSelf(completion: @escaping () -> Void){
        let uName = ConfigHelper.username
        let docRef = db.collection("users").document(uName)
        
        docRef.getDocument(completion: { (document, err) in
            if let document = document, document.exists {
                let email:String  = document.get("email") as! String
                let firstName:String = document.get("firstName") as! String
                let isOnline:Bool = (document.get("isOnline") != nil)
                let lastName:String = document.get("lastName") as! String
                let picURL:String = document.get("profilePictureURL") as! String
                let uid:String = document.get("uid") as! String
                let username:String = document.get("username") as! String
                ATCRemoteData.channelIds = document.get("channels") as! [String]
                
                print("CHANNELID COUNT: \(ATCRemoteData.channelIds.count)")
               
                ATCRemoteData.user = ATCUser(uid: uid, firstName: firstName, lastName: lastName, avatarURL: picURL, email: email, isOnline: isOnline)
                
                let friendsList: [String] = document.get("friends") as! [String]
                
                //getSelf() calls getFriends.
                self.getFriends(friends: friendsList, completion: {
                    //When getFriends() sends completion, getSelf() sends completion
                    //to AppDelegate
                    completion()
                })
            }
        })
    }
    
    func getChannelName(channelId: String, completion: @escaping((ATCUser?) -> ())) -> String {
        var otherUser: ATCUser = ATCUser()
        let docRef = db.collection("channels").document(channelId)
        docRef.getDocument(completion: { (document, err) in
            if let document = document, document.exists{
                for participant in document.get("participants") as! [String]{
                    if(participant != ConfigHelper.username){
                        self.getDbUserFromUname(username: participant, completion:{
                            res in
                            completion(res!)
                        })
                    }
                }
            }
        })
        return "nothing"
    }
    
    func getChannels(completion: @escaping (_ theseThreads: [ATChatMessage]) -> Void){
        if(ATCRemoteData.channels.isEmpty) {completion([])}
        var theseThreads: [ATChatMessage] = []
        
        for channelId in ATCRemoteData.channelIds{
            let docRef = db.collection("channels").document(channelId)
            docRef.getDocument(completion: { (document, err) in
                if let document = document, document.exists{
                    print(document.documentID)
                    var otherUser: ATCUser = ATCUser()
                    let channel = ATCChatChannel(id: document.get("id") as! String, name: otherUser.fullName(), otherUser: otherUser)
                    
                    if(!ATCRemoteData.channels.contains(channel)){
                        ATCRemoteData.channels.append(channel)
                    }
                    
                    self.db.collection("channels/\(channelId)/thread").order(by: "created", descending: true).limit(to: 1).getDocuments() { (otherSnapshot, err) in
                        
                        if(!otherSnapshot!.isEmpty){
                            let doc = otherSnapshot!.documents[0]
                            let thread: ATChatMessage = ATChatMessage(document: doc)!
                            if(!ATCRemoteData.threads.contains(thread)){
                                theseThreads.append(thread)
                                ATCRemoteData.threads.append(thread)
                            }
                            if(theseThreads.count == ATCRemoteData.channels.count){
                                completion(theseThreads)
                            }
                        }
                    }
                }
                else{
                    completion([])
                    return
                }
            })
        }
    }
    
    func getFriends(friends: [String],completion: @escaping () -> Void){
        let count = 0
        for friend in friends {
            let docRef = db.collection("users").document(friend)
            docRef.getDocument(completion: { (document, err) in
                if let document = document, document.exists {
                    let email:String  = document.get("email") as! String
                    let firstName:String = document.get("firstName") as! String
                    let isOnline:Bool = (document.get("isOnline") != nil)
                    let lastName:String = document.get("lastName") as! String
                    let picURL:String = document.get("profilePictureURL") as! String
                    let uid:String = document.get("uid") as! String
                    let username:String = document.get("username") as! String
                    
                    let thisFriend = ATCUser(uid: uid, firstName: firstName, lastName: lastName, avatarURL: picURL, email: email, isOnline: isOnline)
                    thisFriend.setFriend(isFriend: true)
                    
                    if(!ATCRemoteData.friends.contains(thisFriend)){
                        ATCRemoteData.friends.append(thisFriend)
                    }
                    
                    if(ATCRemoteData.friends.count == friends.count){
                        completion()
                    }
                }
            })
           
        }
//        print("getting all friends")
//         db.collection("friends").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Firebase returned an error while getting chat documents: \(err)")
//            } else {
//                if querySnapshot?.documents == nil{
//                    print("no channels or threads found for this user's organization\n. No worries a brand new one will automatically be created when you first attempt to send a message")
//                }else{
////                     Uncomment to see all documents in this user's org
////                     Usually a bad thing though, only use to debug and do not release
//                    for document in querySnapshot!.documents {
                        
//
                        
//
//                        print("REMOTEDATA FRIEND: \(friend.fullName())")
//
//                        ATCRemoteData.friends.append(friend)
//                        //print("\(document.documentID) => \(document.data())")
//                    }
//                    print("getFriends Sending completion")
//                    getChannels(completion: {
//                        completion()
//                    })
//                }
//            }
//        }
    }
    
    func addFriend(username: String){
        let docRef = db.collection("users").document(ConfigHelper.username)
        docRef.updateData([
            "friends": FieldValue.arrayUnion([username])
        ])
        
        let otherRef = db.collection("users").document(username)
        otherRef.updateData([
            "friends": FieldValue.arrayUnion([ConfigHelper.username])
        ])
    }
    
    /// Function ensures that all
    func checkPath(path: [String], dbRepresentation: [String:Any], completion: @escaping (_ channelName: String) -> String){
        db.collection(path[0]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if querySnapshot?.documents != nil {
                    let channelIDRef = self.db.collection(path[0]).document(path[1])
                    channelIDRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            print("1 chat thread exists for \(path[1])")
                            completion(path[1])
                            
                        } else {
                            let splitPath = path[1].components(separatedBy: ":")
                            print("2 chat thread exists for \(path[1])")
                            let newChannelRef = self.db.collection(path[0]).document("\(splitPath[1]):\(splitPath[0])")
                            newChannelRef.getDocument { (newDocument, error) in
                                if let newDocument = newDocument, newDocument.exists{
                                    completion("\(splitPath[1]):\(splitPath[0])")
                                }
                                else{
                                    var modifiedDBRepresentation = dbRepresentation
                                    
                                    // We will always have a thread ID with participants separated
                                    // by a ':' character, so let's work with that
                                    if let participants = (dbRepresentation["id"] as? String)?.components(separatedBy: ":"){
                                        modifiedDBRepresentation["participants"] = participants
                                    }else{
                                        print("somehow we didn't have participant IDs, big issues")
                                    }
                                    
                                    print("chat thread does not currently exist for \(dbRepresentation)")
                                    print("creating chat thread for \(dbRepresentation)")
                                    channelIDRef.setData(dbRepresentation) { err in
                                        if let err = err {
                                            print("Firestore error returned when creating chat thread!: \(err)")
                                        } else {
                                            print("chat thread successfully created")
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }else{
                    print("querySnapshot.documents was nil")
                    // TODO: usually, you don't want all of your users to see all of the other users of your app
                    // append an organization or "group" name to the path, BEFORE channels to make sure your user
                    // groups do not bleed over
                    self.db.collection(path[0]).document(path[1]).setData(dbRepresentation){ err in
                        if let err = err {
                            print("Firestore error returned when creating chat thread!: \(err)")
                        } else {
                            print("chat channel and thread successfully created!")
                            completion(path[1])
                        }
                    }
                }
            }
        }
    }
    
    func addChannelToUsers(channelID: String, users: [ATCUser]){
        if(!ATCRemoteData.channelIds.contains(channelID)){
            
            ATCRemoteData.channelIds.append(channelID)
        }
        for user in users {
            let docRef = db.collection("users").document(user.uid!)
            
            docRef.updateData([
                "channels": FieldValue.arrayUnion([channelID])
            ])
        }
    }
    
    func getDbUserFromUname(username: String, completion:@escaping((ATCUser?) -> ())){
        let docRef = db.collection("users").document("\(username)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let email:String  = document.get("email") as! String
                let firstName:String = document.get("firstName") as! String
                let isOnline:Bool = (document.get("isOnline") != nil)
                let lastName:String = document.get("lastName") as! String
                let picURL:String = document.get("profilePictureURL") as! String
                let uid:String = document.get("uid") as! String
                let username:String = document.get("username") as! String
                
                let thisFriend = ATCUser(uid: uid, firstName: firstName, lastName: lastName, avatarURL: picURL, email: email, isOnline: isOnline)
                completion(thisFriend)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    func getATCFriendFromUname(username: String) -> ATCUser{
        for friend in ATCRemoteData.friends{
            if(friend.username == username){
                return friend
            }
        }
        return ATCUser()
    }
    
}
