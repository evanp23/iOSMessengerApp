//
//  ContactViewController.swift
//  ChatApp
//
//  Created by Evan Phillips on 3/27/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation
import UIKit

class ContactViewController : UIViewController{
    let label = UILabel()
    let contactName : String
    
    init(contactName : String){
        self.contactName = contactName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        label.text = self.contactName
        self.view.addSubview(label)
        
    }
}
