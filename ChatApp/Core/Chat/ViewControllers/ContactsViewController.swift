import UIKit

class ContactsViewController : ATCGenericCollectionViewController{
    
    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         dataSource: ATCGenericCollectionViewControllerDataSource){
        
        super.init(configuration: configuration, selectionBlock: selectionBlock)
        self.use(adapter: ContactAdapter(uiConfig: uiConfig, viewer: ATCRemoteData.user), for: "ATCUser")
        self.title = "Contacts"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func contactsVC(uiConfig: ATCUIGenericConfigurationProtocol,
                           friendsDataSource: ATCGenericCollectionViewControllerDataSource) -> ContactsViewController {
        print("contacts 1")
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false, pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor, collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor, collectionViewLayout: ATCLiquidCollectionViewLayout(), collectionPagingEnabled: false, hideScrollIndicators: false, hidesNavigationBar: false, headerNibName: nil, scrollEnabled: true, uiConfig: uiConfig)
        
        
        let vc = ContactsViewController(configuration: collectionVCConfiguration, uiConfig: uiConfig, selectionBlock: ContactsViewController.contactSelectionBlock(uiConfig: uiConfig), dataSource: friendsDataSource)
        
        vc.genericDataSource = friendsDataSource
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func contactSelectionBlock(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCollectionViewSelectionBlock{
        return { (navController, object) in
          let config = ATCChatUIConfiguration(primaryColor: UIColor(hexString: "#0084ff"),
                secondaryColor: UIColor(hexString: "#f0f0f0"),
                inputTextViewBgColor: UIColor(hexString: "#f4f4f6"),
                inputTextViewTextColor: .black,
                inputPlaceholderTextColor: UIColor(hexString: "#979797"))
          if let contact = object as? ATCUser {
              let vc = ContactViewController(contact: contact)
              navController?.pushViewController(vc, animated: true)
              print("clicked: \(contact.fullName())")
          }
        }
    }
}
