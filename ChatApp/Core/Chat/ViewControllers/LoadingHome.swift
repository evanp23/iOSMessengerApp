//
//  LoadingHome.swift
//  ChatApp
//
//  Created by Evan Phillips on 3/20/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation
import UIKit

class LoadingHome : UIViewController{
//    let message: String = ""
//    init(message: String){
//        self.message = message
//    }
    
    func showLoad(){
        let loadingText = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 100.0))
        loadingText.text = "hello"
    }
    
}
