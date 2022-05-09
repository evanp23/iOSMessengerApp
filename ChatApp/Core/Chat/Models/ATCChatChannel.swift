//
//  ATCChatChannel.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/26/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore

struct ATCChatChannel {
    let id: String
    let name: String
    let otherUser: ATCUser

    init(id: String, name: String, otherUser: ATCUser) {
        self.id = id
        self.name = name
        self.otherUser = otherUser
    }

    init?(document: QueryDocumentSnapshot) {
        id = document.documentID
        let particArray = id.components(separatedBy: ":")
        let remoteData = ATCRemoteData()
        
        if(particArray[0] == ConfigHelper.username){
            let theOtherUser = remoteData.getATCFriendFromUname(username: particArray[1])
            self.name = theOtherUser.fullName()
            self.otherUser = theOtherUser
        }
        else{
            let theOtherUser = remoteData.getATCFriendFromUname(username: particArray[1])
            self.name = theOtherUser.fullName()
            self.otherUser = theOtherUser
        }
    }
}

extension ATCChatChannel: DatabaseRepresentation {

    var representation: [String : Any] {
        var rep = ["name": name]
        rep["id"] = id
        return rep
    }

}

extension ATCChatChannel: Comparable {

    static func == (lhs: ATCChatChannel, rhs: ATCChatChannel) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: ATCChatChannel, rhs: ATCChatChannel) -> Bool {
        return lhs.name < rhs.name
    }

}
