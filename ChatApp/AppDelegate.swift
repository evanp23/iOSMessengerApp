//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure the UI
        let config = ChatUIConfiguration()
        config.configureUI()
        
        
        let data = ConfigHelper.readConfig()
        if(data == nil){
            print("Data is nil")
        }
        else{
            ConfigHelper.parse(jsonData: data!)
        }
        
        

        FirebaseApp.configure()
        let remoteData = ATCRemoteData()
        

        //let threadsDataSource = ATCGenericLocalHeteroDataSource(items: ATCChatMockStore.threads)
        
        
        
//        let initialData = ATCGenericFirebaseDataSource<<#T: ATCGenericBaseModel & ATCGenericFirebaseParsable#>>(tableName: "channels")
        
        
        
        //let threadsDataSource = ATCGenericFirebaseDataSource<ATCChatChannel>(tableName: "threads")
        
        // HEY THERE, user. read the next few lines below
        // Helper file to access remote data for a user
        
        // Checks if user's firestore actually has channels setup
        
        
        // For testing, set this to a usr from 0-4 and run it to your simulator
        // Then, set it to any other user and run it to your phone. THEN-> see my comment in ATCChatMockStore.swift
        //let user = 2
        // If both devices have a different user active, AND the chat thread is available, you can msg live
        
        
        // Window setup
        window = UIWindow(frame: UIScreen.main.bounds)
        let loader = LoadingHome()
        loader.showLoad()
//        self.window?.rootViewController = ChatHostViewController(uiConfig: config,
//                                                                 threadsDataSource: threadsDataSource,
//                                                                 viewer: remoteData.user)
        
        //AppDelegate calling getSelf() with completion handler.
        remoteData.getSelf(completion: {
            //this code is run after getSelf() sends completion.
            self.window?.rootViewController = ChatHostViewController(uiConfig: config,
                                                                threadsDataSource: ChatChannelDataStore(),
                                                                     viewer: ATCRemoteData.user)
        })
        
        let loading = LoadingHome()
        loading.showLoad()
        
        self.window?.rootViewController = loading
        
        print("currentUser: \(ATCRemoteData.user.fullName())")
        window?.makeKeyAndVisible()

        return true
    }
}
