//
//  ContactViewController.swift
//  ChatApp
//
//  Created by Evan Phillips on 3/27/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation
import UIKit
import InputBarAccessoryView

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
//        let contactStack = InputStackView(axis: .vertical, spacing: 15)
        
        setContactImg()
        
        
    let messageButton: UIButton = {
        var myButton: UIButton = UIButton()
        myButton.setImage(UIImage.localImage("bubbles-icon", template: true), for: UIControl.State.normal)
        myButton.addTarget(self, action: #selector(messageButtonClicked), for: .touchUpInside)
        return myButton
    }()
        
        let addContactButton: UIButton = {
            var addButton: UIButton = UIButton()
            addButton.setImage(UIImage.localImage("three-equal-lines-icon", template: true), for: UIControl.State.normal)
            addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
            return addButton
            
        }()
        
        
        
        
//        contactImg.center = view.center
        label.text = self.contact.fullName()
        let textPos = view.center.x
        
        
        lazy var actionsStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            
            if(!contact.getIsFriend()){
                [addContactButton].forEach { stack.addArrangedSubview($0) }
            }
            else{
                [messageButton].forEach{ stack.addArrangedSubview($0)}
            }
            
            return stack
        }()
        
        lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 20.0
            stack.alignment = .center
//            stack.distribution = .fillEqually
            [contactImg, label, actionsStack].forEach { stack.addArrangedSubview($0) }
            return stack
        }()
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.center.x)
            make.centerY.equalTo(view.center.y / 2)
            make.width.equalTo(200)
            make.height.equalTo(275)
//            make.top.equalTo(view.center.y).offset(30)
//              make.height.equalTo(280)
          }
        contactImg.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        //        contactImg.layer.borderWidth = 1.0
                contactImg.layer.masksToBounds = false
                contactImg.layer.borderColor = UIColor.black.cgColor
                contactImg.layer.cornerRadius = contactImg.frame.size.width/2
                contactImg.clipsToBounds = true
        
       stackView.subviews.forEach { $0.layer.cornerRadius = $0.frame.height / 2 }
         
        
    }
    
    @objc func addButtonClicked(){
        print("add \(contact.fullName())")
        let remoteData = ATCRemoteData()
        remoteData.addFriend(username: contact.uid!)
    }
    
    @objc func messageButtonClicked(){
        let viewer = ATCRemoteData.user
        
        let uiConfig = ATCChatUIConfiguration(primaryColor: UIColor(hexString: "#0084ff"),
              secondaryColor: UIColor(hexString: "#f0f0f0"),
              inputTextViewBgColor: UIColor(hexString: "#f4f4f6"),
              inputTextViewTextColor: .black,
              inputPlaceholderTextColor: UIColor(hexString: "#979797"))
//        if let lastMessage = object as? ATChatMessage {
//          let otherUser = viewer.uid == lastMessage.atcSender.uid ? lastMessage.recipient : lastMessage.atcSender
        
        var channel = ATCChatChannel(id: "\(contact.uid!):\(viewer.uid!)", name: contact.fullName(), otherUser: contact)
        
        let remoteData = ATCRemoteData()
        remoteData.checkPath(path: ["channels", "\(contact.uid!):\(viewer.uid!)", "thread"], dbRepresentation: channel.representation, completion: {
            channelName in
            
            channel = ATCChatChannel(id: channelName, name: self.contact.fullName(), otherUser: self.contact)
            
            let vc = ATCChatThreadViewController(user: viewer, channel: channel, uiConfig: uiConfig)
            self.navigationController?.pushViewController(vc, animated: true)
            
            return ""
            
        })
        
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
