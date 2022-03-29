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
        
        
        let vc = ContactsViewController(configuration: collectionVCConfiguration, uiConfig: uiConfig, selectionBlock: {(navController, object) in}, dataSource: friendsDataSource)
        
        vc.genericDataSource = friendsDataSource
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello")
    }
    
    func contactSelectionBlock(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCollectionViewSelectionBlock{
        return{[weak self] (navController, object) in
            guard let  `self` = self else{return}
            let uiConfig = ATCChatUIConfiguration(primaryColor: UIColor.red, secondaryColor: UIColor.black, inputTextViewBgColor: UIColor.yellow, inputTextViewTextColor: UIColor.gray, inputPlaceholderTextColor: UIColor.blue)
            let vc = ContactViewController(contactName: "evan")
            navController?.pushViewController(vc, animated: true)
        }
    }
}
