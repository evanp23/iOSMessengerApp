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

    let homeVC: UIViewController
    let uiConfig: ATCUIGenericConfigurationProtocol
    let contactsVC: UIViewController
    

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         viewer: ATCUser) {
        
        let friendsDataSource = ATCGenericLocalHeteroDataSource(items: ATCRemoteData.friends)

        
        
        self.uiConfig = uiConfig
        self.homeVC = ATCChatHomeViewController.homeVC(uiConfig: uiConfig, threadsDataSource: threadsDataSource, viewer: viewer)
        
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
        
        
        self.contactsVC = ContactsViewController.contactsVC(uiConfig: uiConfig, friendsDataSource: friendsDataSource)
        
        let threadsVC = ATCChatThreadsViewController.mockThreadsVC(uiConfig: uiConfig, dataSource: threadsDataSource, viewer: viewer)
        
        print("made threads vc")
        
        
      let contactViewModel = ATCViewControllerContainerViewModel(viewController: contactsVC, cellHeight: nil, subcellHeight: 85)
      contactViewModel.parentViewController = homeVC
        
        print("Viewer: \(viewer.firstName)")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: "Contacts",
              viewController: contactsVC,
              image: UIImage.localImage("customers-icon", template: true),
              type: .viewController,
              leftTopView: nil,
              rightTopView: nil),
            
            ATCNavigationItem(title: "Chats",
              viewController: homeVC,
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
