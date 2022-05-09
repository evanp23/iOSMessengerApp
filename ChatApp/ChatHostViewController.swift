//
//  ChatHostViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase

class ChatHostViewController: UIViewController, UITabBarControllerDelegate {
    let uiConfig: ATCUIGenericConfigurationProtocol
    let homeVC: ATCChatHomeViewController?
    let contactsVC: ContactsViewController?
    let searchVC: SearchViewController?
    

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         viewer: ATCUser) {
        
        let friendsDataSource = ATCGenericLocalHeteroDataSource(items: ATCRemoteData.friends)

        
        
        self.uiConfig = uiConfig
        
        //self.homeVC = ATCChatHomeViewController.homeVC(uiConfig: uiConfig, threadsDataSource: threadsDataSource, viewer: viewer)
        
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
        
        
        var storiesVC = ATCChatHomeViewController.storiesViewController(uiConfig: uiConfig,
                                                   dataSource: ATCGenericLocalDataSource<ATCUser>(items: ATCRemoteData.friends),
                                                   viewer: ATCRemoteData.user)
        
        self.contactsVC = ContactsViewController.contactsVC(uiConfig: uiConfig, friendsDataSource: friendsDataSource)
        
        var threadsVC = ATCChatThreadsViewController(configuration: collectionVCConfiguration, selectionBlock: ATCChatThreadsViewController.selectionBlock(viewer: viewer), viewer: viewer)
        
        
        self.homeVC = ATCChatHomeViewController(configuration: collectionVCConfiguration, selectionBlock: ATCChatHomeViewController.storySelectionBlock(viewer: viewer), viewer: viewer)
        
        let storiesCarousel = ATCCarouselViewModel(title: nil,
                                                   viewController: storiesVC,
                                                   cellHeight: 105)
        storiesCarousel.parentViewController = homeVC
        
        
        threadsVC.genericDataSource = threadsDataSource
        threadsVC.genericDataSource?.loadFirst()
        
        let threadsViewModel = ATCViewControllerContainerViewModel(viewController: threadsVC, cellHeight: nil, subcellHeight: 85)
        threadsViewModel.parentViewController = self.homeVC
        self.homeVC!.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
      
      // Finish home VC configuration
        self.homeVC!.genericDataSource = ATCGenericLocalHeteroDataSource(items: [storiesCarousel, threadsViewModel])
        
        
        print("made threads vc")
        
        
      let contactViewModel = ATCViewControllerContainerViewModel(viewController: contactsVC!, cellHeight: nil, subcellHeight: 85)
      contactViewModel.parentViewController = homeVC
        
        self.searchVC = SearchViewController(viewer: viewer)
        
        //SET CHANNEL LISTENER
        let remoteData = ATCRemoteData()
        let thisDb = remoteData.db
        
        let thisReference: DocumentReference? = thisDb.collection("users").document(ConfigHelper.username)
//        let thisListener = thisReference?.addSnapshotListener { querySnapshot, error in
//          guard let document = querySnapshot else {
//            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
//            return
//          }
//            guard let data = document.data() else{
//                print("Document data was empty")
//                return
//            }
//            let channels = document.get("channels") as! [String]
//            
//            let remoteData = ATCRemoteData()
//            
//            for channel in channels {
//                print("CHannel : \(channel)")
//                
//                let splitChannelId = channel.components(separatedBy: ":")
//                let otherUser : ATCUser = splitChannelId[0] == ConfigHelper.username ? remoteData.getATCFriendFromUname(username: splitChannelId[1]) : remoteData.getATCFriendFromUname(username: splitChannelId[0])
//                
//                let newChannel = ATCChatChannel(id: channel, name: otherUser.fullName(), otherUser: otherUser)
//                if(!ATCRemoteData.channels.contains(newChannel)){
//                    ATCRemoteData.channels.append(newChannel)
//                }
////                threadsVC.genericDataSource?.loadFirst()
//            }
//        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: "Search",
              viewController: self.searchVC!,
              image: UIImage.localImage("three-equal-lines-icon", template: true),
              type: .viewController,
              leftTopView: nil,
              rightTopView: nil),
            
            ATCNavigationItem(title: "Contacts",
              viewController: contactsVC!,
              image: UIImage.localImage("customers-icon", template: true),
              type: .viewController,
              leftTopView: nil,
              rightTopView: nil),
            
            ATCNavigationItem(title: "Chats",
              viewController: homeVC!,
              image: UIImage.localImage("bubbles-icon", template: true),
              type: .viewController,
              leftTopView: nil,
              rightTopView: nil),
            
        ]
        let menuConfiguration = ATCMenuConfiguration(user: nil,
             cellClass: ATCCircledIconMenuCollectionViewCell.self,
             headerHeight: 0,
             items: menuItems,
             uiConfig: ATCMenuUIConfiguration(itemFont: uiConfig.regularMediumFont,
              tintColor: uiConfig.mainTextColor,
              itemHeight: 45.0,
              backgroundColor: uiConfig.mainThemeBackgroundColor))

        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
          style: .tabBar,
          topNavigationRightView: nil,
          topNavigationLeftImage: UIImage.localImage("three-equal-lines-icon", template: true),
          topNavigationTintColor: uiConfig.mainThemeForegroundColor,
          statusBarStyle: uiConfig.statusBarStyle,
          uiConfig: uiConfig)
        return ATCHostViewController(configuration: config)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewControllerWithView(hostController)
        hostController.view.backgroundColor = uiConfig.mainThemeBackgroundColor
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return uiConfig.statusBarStyle
    }
}
