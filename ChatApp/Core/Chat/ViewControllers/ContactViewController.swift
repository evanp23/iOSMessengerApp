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
    let contact: ATCUser
    
    private let contactImg: UIImageView = {
        let contactImg = UIImageView()
        contactImg.contentMode = .scaleAspectFill
        contactImg.backgroundColor = .white
        return contactImg
    }()
    
    init(contact: ATCUser){
        self.contact = contact
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContactImg()
        view.addSubview(contactImg)
        contactImg.frame = CGRect(x: view.center.x / 2, y: view.center.y / 3, width: 200, height: 200)
//        contactImg.layer.borderWidth = 1.0
        contactImg.layer.masksToBounds = false
        contactImg.layer.borderColor = UIColor.black.cgColor
        contactImg.layer.cornerRadius = contactImg.frame.size.width/2
        contactImg.clipsToBounds = true
        
//        contactImg.center = view.center
        label.text = self.contact.fullName()
        let textPos = view.center.x
        
        label.frame = CGRect(x: view.center.x, y: view.center.y, width: 250, height: 100)
        
        self.view.addSubview(label)
        
    }
    
    func setContactImg(){
        guard let urlString = self.contact.profilePictureURL else { return }
        let url = URL(string: urlString)!
        
        guard let data = try? Data(contentsOf: url) else{
            return
        }
        contactImg.image = UIImage(data: data)
    }
}
