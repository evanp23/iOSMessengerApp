//
//  ATCChatHomeViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import Firebase

class ATCChatHomeViewController: ATCGenericCollectionViewController {
    private var messageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private var reference: DocumentReference?
    
  
  init(configuration: ATCGenericCollectionViewControllerConfiguration,
       selectionBlock: ATCollectionViewSelectionBlock?,
       viewer: ATCUser) {
    
    super.init(configuration: configuration, selectionBlock: selectionBlock)
    
    self.title = "Chats"
    
      
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
  static func homeVC(uiConfig: ATCUIGenericConfigurationProtocol,
                     threadsDataSource: ATCGenericCollectionViewControllerDataSource,
                     viewer: ATCUser) -> ATCChatHomeViewController {
    let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
      pullToRefreshEnabled: false,
      pullToRefreshTintColor: .gray,
      collectionViewBackgroundColor: .white,
      collectionViewLayout: ATCLiquidCollectionViewLayout(),
      collectionPagingEnabled: false,
      hideScrollIndicators: false,
      hidesNavigationBar: false,
      headerNibName: nil,
      scrollEnabled: true,
      uiConfig: uiConfig
    )
      
    
      
      
    
    let homeVC = ATCChatHomeViewController(configuration: collectionVCConfiguration, selectionBlock: { (navController, object) in
      
    }, viewer: viewer)
    
      var storiesVC = self.storiesViewController(uiConfig: uiConfig,
                                                 dataSource: ATCGenericLocalDataSource<ATCUser>(items: ATCRemoteData.friends),
                                                 viewer: ATCRemoteData.user)
    
      
    
    // Configure Stories carousel
    
    let storiesCarousel = ATCCarouselViewModel(title: nil,
                                               viewController: storiesVC,
                                               cellHeight: 105)
    storiesCarousel.parentViewController = homeVC
    
    // Configure list of message threads
      
      var threadsVC = ATCChatThreadsViewController(configuration: collectionVCConfiguration, selectionBlock: ATCChatThreadsViewController.selectionBlock(viewer: viewer), viewer: viewer)
      
//      var threadsVC = ATCChatThreadsViewController.mockThreadsVC(uiConfig: uiConfig, dataSource: threadsDataSource, viewer: viewer)
      
      threadsVC.genericDataSource = threadsDataSource
//      threadsVC.genericDataSource?.loadFirst()
      
      
      //NEW THREAD LISTENER
      
      let remoteData = ATCRemoteData()
      let thisDb = remoteData.db
      
      let thisReference: DocumentReference? = thisDb.collection("users").document(ConfigHelper.username)
      
    let thisListener = thisReference?.addSnapshotListener { querySnapshot, error in
      guard let document = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
        guard let data = document.data() else{
            print("Document data was empty")
            return
        }
        let channels = document.get("channels") as! [String]
        
        let remoteData = ATCRemoteData()
        
        for channel in channels {
            print("CHannel : \(channel)")
            
            let splitChannelId = channel.components(separatedBy: ":")
            let otherUser : ATCUser = splitChannelId[0] == ConfigHelper.username ? remoteData.getATCFriendFromUname(username: splitChannelId[1]) : remoteData.getATCFriendFromUname(username: splitChannelId[0])
            
            let newChannel = ATCChatChannel(id: channel, name: otherUser.fullName(), otherUser: otherUser)
            if(!ATCRemoteData.channels.contains(newChannel)){
                ATCRemoteData.channels.append(newChannel)
            }
            
//            threadsVC.genericDataSource?.loadFirst()
        }
        threadsVC.collectionView.reloadData()
        print("Thread count: \(threadsVC.genericDataSource?.numberOfObjects())")
    }
      
      
      
      let threadsViewModel = ATCViewControllerContainerViewModel(viewController: threadsVC, cellHeight: nil, subcellHeight: 85)
    threadsViewModel.parentViewController = homeVC
    homeVC.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
    
    // Finish home VC configuration
    homeVC.genericDataSource = ATCGenericLocalHeteroDataSource(items: [storiesCarousel, threadsViewModel])
      
      
    return homeVC
  }
  
  
  static func storiesViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                                    dataSource: ATCGenericCollectionViewControllerDataSource,
                                    viewer: ATCUser) -> ATCGenericCollectionViewController {
    let layout = ATCCollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
        pullToRefreshTintColor: .white,
        collectionViewBackgroundColor: .white,
        collectionViewLayout: layout,
        collectionPagingEnabled: false,
        hideScrollIndicators: true,
        hidesNavigationBar: false,
        headerNibName: nil,
        scrollEnabled: true,
        uiConfig: uiConfig)
    let vc = ATCGenericCollectionViewController(configuration: configuration, selectionBlock: ATCChatHomeViewController.storySelectionBlock(viewer: viewer))
    vc.genericDataSource = dataSource
    vc.use(adapter: ATCChatUserStoryAdapter(uiConfig: uiConfig), for: "ATCUser")
      
      
    return vc
  }
  
  static func storySelectionBlock(viewer: ATCUser) -> ATCollectionViewSelectionBlock? {
    return { (navController, object) in
      let uiConfig = ATCChatUIConfiguration(primaryColor: UIColor(hexString: "#0084ff"),
                                            secondaryColor: UIColor(hexString: "#f0f0f0"),
                                            inputTextViewBgColor: UIColor(hexString: "#f4f4f6"),
                                            inputTextViewTextColor: .black,
                                            inputPlaceholderTextColor: UIColor(hexString: "#979797"))
      if let user = object as? ATCUser {
        let id1 = (user.uid ?? "")
        let id2 = (viewer.uid ?? "")
        let channelId = "\(id1):\(id2)"
        print("loading thread for channelID: \(channelId)")
          let vc = ATCChatThreadViewController(user: viewer, channel: ATCChatChannel(id: channelId, name: user.fullName(), otherUser: user), uiConfig: uiConfig)
        navController?.pushViewController(vc, animated: true)
      }
    }
  }
}
