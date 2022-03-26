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
    
    func getSelf(completion: @escaping () -> Void){
        
        db.collection("self").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Firebase returned an error while getting chat documents: \(err)")
            } else {
                if querySnapshot?.documents == nil{
                    print("no channels or threads found for this user's organization\n. No worries a brand new one will automatically be created when you first attempt to send a message")
                }else{
                    var userInfo = querySnapshot!.documents[0]
            
                    let email:String  = userInfo.get("email") as! String
                    let firstName:String = userInfo.get("firstName") as! String
                    let isOnline:Bool = (userInfo.get("isOnline") != nil)
                    let lastName:String = userInfo.get("lastName") as! String
                    let picURL:String = userInfo.get("pictureURL") as! String
                    let uid:String = userInfo.get("uid") as! String
                    let username:String = userInfo.get("username") as! String
                    
                    ATCRemoteData.user = ATCUser(uid: uid, firstName: firstName, lastName: lastName, avatarURL: picURL, email: email, isOnline: isOnline)
                    self.getChannels(completion: {
                        print("getSelf sending completion")
                        completion()
                    })
                }
            }
        }
    }
    
    func getChannels(completion: @escaping () -> Void){
        print("getting all channels")
        db.collection("channels").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Firebase returned an error while getting chat documents: \(err)")
            } else {
                if querySnapshot?.documents == nil{
                    print("no channels or threads found for this user's organization\n. No worries a brand new one will automatically be created when you first attempt to send a message")
                }else{
                    // Uncomment to see all documents in this user's org
                    // Usually a bad thing though, only use to debug and do not release
                    self.getFriends(completion: {
                        for document in querySnapshot!.documents {
                            let document1 = ATCChatChannel(document: document)
                            //get threads
                            self.db.collection("channels/\(document.get("id")!)/thread").getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Firebase returned an error while getting chat documents: \(err)")
                                } else {
                                    if querySnapshot?.documents == nil{
                                        print("no channels or threads found for this user's organization\n. No worries a brand new one will automatically be created when you first attempt to send a message")
                                    }else{
                                        if(!querySnapshot!.isEmpty){
                                            let doc = querySnapshot!.documents[0]
                                            let thread: ATChatMessage = ATChatMessage(document: doc)!
                                            ATCRemoteData.threads.append(thread)
                                        }
                                        completion()
                                    }
                                }
                            }
                            
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    func getFriends(completion: @escaping () -> Void){
        print("getting all friends")
         db.collection("friends").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Firebase returned an error while getting chat documents: \(err)")
            } else {
                if querySnapshot?.documents == nil{
                    print("no channels or threads found for this user's organization\n. No worries a brand new one will automatically be created when you first attempt to send a message")
                }else{
//                     Uncomment to see all documents in this user's org
//                     Usually a bad thing though, only use to debug and do not release
                    for document in querySnapshot!.documents {
                        let email:String  = document.get("email") as! String
                        let firstName:String = document.get("firstName") as! String
                        let isOnline:Bool = (document.get("isOnline") != nil)
                        let lastName:String = document.get("lastName") as! String
                        let picURL:String = document.get("pictureURL") as! String
                        let uid:String = document.get("uid") as! String
                        let username:String = document.get("username") as! String
                        
                        let friend = ATCUser(uid: uid, firstName: firstName, lastName: lastName, avatarURL: picURL, email: email, isOnline: isOnline)
                        
                        print("REMOTEDATA FRIEND: \(friend.fullName())")
                        
                        ATCRemoteData.friends.append(friend)
                        //print("\(document.documentID) => \(document.data())")
                    }
                    print("getFriends Sending completion")
                    completion()
                }
            }
        }
    }
    
    /// Function ensures that all
    func checkPath(path: [String], dbRepresentation: [String:Any]){
        print("checking for the db snapshopt of main chat store: '\(path[0])'")
        db.collection(path[0]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if querySnapshot?.documents != nil {
                    print("checking for channelID: \(path[1])")
                    let channelIDRef = self.db.collection(path[0]).document(path[1])
                    channelIDRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            print("chat thread exists for \(dbRepresentation)")
                            // Uncomment to see the data description
                            //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        } else {
                            print("adding indexable values to the database representation")
                            var modifiedDBRepresentation = dbRepresentation
                            
                            // We will always have a thread ID with participants separated
                            // by a ':' character, so let's work with that
                            if let participants = (dbRepresentation["id"] as? String)?.components(separatedBy: ":"){
                                modifiedDBRepresentation["participants"] = participants
                                // Now, on Firestore, set your database to be indexed on "participants"
                                // This allows you to search for all documents that have a particular participant present
                                // say for example, retrieving only the threads to which the current logged-in user belongs
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
                        }
                    }
                }
            }
        }
    }
    
}
