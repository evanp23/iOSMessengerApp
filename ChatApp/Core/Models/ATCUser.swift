//
//  ATCUser.swift
//  AppTemplatesCore
//
//  Created by Florian Marcu on 2/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import MessageKit

open class ATCUser: NSObject, ATCGenericBaseModel {

    var uid: String?
    var username: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var profilePictureURL: String?
    var isOnline: Bool
    var channels: [String:String]
    var isFriend: Bool = false;
    
    public override init() {
        self.firstName = nil
        self.lastName = nil
        self.uid = nil
        self.email = nil
        self.profilePictureURL = nil
        self.isOnline = false
        self.channels = [:]
    }

    public init(uid: String = "", firstName: String, lastName: String, avatarURL: String = "", email: String = "", isOnline: Bool = false, channels: [String:String] = [:]) {
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
        self.email = email
        self.profilePictureURL = avatarURL
        self.isOnline = isOnline
        self.channels = channels
    }
    

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

//    public func mapping(map: Map) {
//        username            <- map["username"]
//        email               <- map["email"]
//        firstName           <- map["first_name"]
//        lastName            <- map["last_name"]
//        profilePictureURL   <- map["profile_picture"]
//    }

    public func fullName() -> String {
        guard let firstName = firstName, let lastName = lastName else { return "" }
        return "\(firstName) \(lastName)"
    }

    var initials: String {
        if let f = firstName?.first, let l = lastName?.first {
            return String(f) + String(l)
        }
        return "?"
    }
    
    func setFriend(isFriend: Bool){
        self.isFriend = isFriend
    }
    
    func getIsFriend() -> Bool{
        return self.isFriend
    }
}
