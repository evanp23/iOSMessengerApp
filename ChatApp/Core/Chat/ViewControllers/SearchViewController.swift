//
//  SearchViewController.swift
//  ChatApp
//
//  Created by Evan Phillips on 4/25/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var labels: [String: UILabel] = [:]
    var searchedNames:[String] = []
    var viewer: ATCUser
    var initialLabel: UILabel?
    var labelCount = 0
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    
    init(viewer: ATCUser){
        self.viewer = viewer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        
        let searchField =  UITextField(frame: CGRect(x: 50, y: 100, width: 300, height: 40))
        searchField.placeholder = "Enter text here"
        searchField.font = UIFont.systemFont(ofSize: 15)
        searchField.borderStyle = UITextField.BorderStyle.roundedRect
        searchField.autocorrectionType = UITextAutocorrectionType.no
        searchField.keyboardType = UIKeyboardType.default
        searchField.returnKeyType = UIReturnKeyType.done
        searchField.clearButtonMode = UITextField.ViewMode.whileEditing
        searchField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.view.addSubview(searchField)
        
        setUpTableView(searchField: searchField)
        
        
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        

//        self.labels["initial"] = showLabelWithText(text: "Search your friends or messages!")
    }
    
    func setUpTableView(searchField: UITextField){
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchedNames.removeAll()
        tableView.reloadData()
        print(textField.text!)
        if(textField.text == nil){
            print("isEmpty")
            tableView.reloadData()
            return
        }
        else{
            let db = Firestore.firestore()
            db.collection("users").getDocuments(){(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.documents != nil {
                        for i in 0...(((querySnapshot?.documents.count)! - 1) ){
                            let firstName: String = (querySnapshot?.documents[i].get("firstName")!) as! String
                            let lastName: String = querySnapshot?.documents[i].get("lastName")! as! String
                            let uid: String = querySnapshot?.documents[i].get("uid")! as! String
                            
                            let fullName = "\(firstName) \(lastName)"
                            
                            let matchName = (fullName.lowercased()).contains(textField.text!.lowercased())
                            let matchUid = (uid.lowercased()).contains(textField.text!.lowercased())
                            let alreadyContains = self.searchedNames.contains("\(fullName) - \(uid)")
                            
                            if(!alreadyContains && (matchName || matchUid)){
                                self.searchedNames.append("\(fullName) - \(uid)")
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
//            for friend in ATCRemoteData.friends{
//                if((friend.fullName().lowercased()).contains(textField.text!.lowercased()) || (friend.uid!.lowercased()).contains(textField.text!.lowercased())){
//                    print(friend.fullName())
//
//                }
//            }
        }
        
        
//        if(textField.text! == ""){
//            self.labels["initial"] = showLabelWithText(text: "Search your friends or messages!")
//            for friend in ATCRemoteData.friends{
//                if self.labels.keys.contains(friend.fullName()){
//                    removeLabel(label: self.labels[friend.fullName()]!)
//                    self.labels.removeValue(forKey: friend.fullName())
//                }
//            }
//        }
//        else{
//            removeLabel(label: self.labels["initial"]!)
//            for friend in ATCRemoteData.friends{
//                if friend.fullName().contains(textField.text!){
//                    self.labels[friend.fullName()] = showLabelWithText(text: friend.fullName())
//                    print(friend.fullName())
//                }
//                else if self.labels.keys.contains(friend.fullName()){
//                    removeLabel(label: self.labels[friend.fullName()]!)
//                    self.labels.removeValue(forKey: friend.fullName())
//                }
//            }
//        }
    }
//
//    func showLabelWithText(text: String) -> UILabel{
//        self.labelCount += 1
//        let label: UILabel = {
//            let thisLabel = UILabel()
//            thisLabel.text = text
//            thisLabel.frame = CGRect(x: 50, y: 100 * self.labelCount, width: 300, height: 200)
//            return thisLabel
//        }()
//        view.addSubview(label)
//        return label
//    }
//
//    func removeLabel(label: UILabel){
//        label.removeFromSuperview()
//        self.labelCount -= 1
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchedNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int{
        return searchedNames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        print("\(searchedNames[indexPath.row])")
        
        let nameAndUid = searchedNames[indexPath.row].components(separatedBy: " - ")
        let username = nameAndUid[1]
        
        let remoteData = ATCRemoteData()
        remoteData.getDbUserFromUname(username: username) { user in
            let config = ATCChatUIConfiguration(primaryColor: UIColor(hexString: "#0084ff"),
                  secondaryColor: UIColor(hexString: "#f0f0f0"),
                  inputTextViewBgColor: UIColor(hexString: "#f4f4f6"),
                  inputTextViewTextColor: .black,
                  inputPlaceholderTextColor: UIColor(hexString: "#979797"))
            for friend in ATCRemoteData.friends{
                if(friend.uid == user?.uid){
                    print("\(user?.uid) is friend")
                    user?.setFriend(isFriend: true)
                }
            }
            let vc = ContactViewController(contact: user!)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
        
}

