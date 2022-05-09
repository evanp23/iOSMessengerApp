//
//  ChatChannelDataStore.swift
//  ChatApp
//
//  Created by Evan Phillips on 4/18/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChatChannelDataStore: ATCGenericCollectionViewControllerDataSource{
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    let remoteData = ATCRemoteData()
    
    var threads: [ATChatMessage] = []
    var user: ATCUser? = nil
    var participationListener: ListenerRegistration? = nil
    var channelListener: ListenerRegistration? = nil
    var isLoading: Bool = false
    
    deinit{
        participationListener?.remove()
        channelListener?.remove()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < threads.count{
            return threads[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int{
        return threads.count
    }
    
    func loadFirst(){
        
        self.user = ATCRemoteData.user
//        channelListener = Firestore.firestore().collection("channels").addSnapshotListener({[weak self] (querySnapshot, error) in
//            guard let strongSelf = self else {return}
//            guard querySnapshot != nil else{
//                print("Error listening for channel updates: \(error)")
//                return
//            }
//            print("LISTENER")
//            guard(strongSelf.user?.uid) != nil else{return}
//            strongSelf.loadIfNeeded()
//        })
        loadIfNeeded()
        
    }
    
    func loadBottom() {}
    func loadTop() {}
    
    fileprivate func loadIfNeeded(){
        guard let user = user else{
            self.threads = []
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: threads)
            return
        }
        if(isLoading){
            return
        }
        
        isLoading = true
        
        let remoteData = ATCRemoteData()
        remoteData.getChannels(completion: {[weak self] (theseThreads) in
            guard let strongSelf = self else {return}
            strongSelf.threads = theseThreads
            
            strongSelf.delegate?.genericCollectionViewControllerDataSource(strongSelf, didLoadFirst: theseThreads)
            strongSelf.isLoading = false
        })
    }
}
