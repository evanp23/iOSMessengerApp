//
//  Config.swift
//  ChatApp
//
//  Created by Evan Phillips on 4/15/22.
//  Copyright © 2022 Instamobile. All rights reserved.
//

import Foundation

struct userData: Codable {
    let username: String
}

class ConfigHelper{
    static var username: String = ""
    
//    init(configPath: String){
//        self.path = configPath
//        self.username = ""
//    }
    
    static func readConfig() -> Data? {
        do{
            if let filePath = Bundle.main.path(forResource: "config", ofType: "json") {
                print("GOT FILE")
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                
                return data
            }
            else{
                print("DIDN'T GET FILE")
            }
        }catch{
            print(error)
        }
        
        return nil
    }
    
    static func parse(jsonData: Data){
        do{
            let decodedData = try JSONDecoder().decode(userData.self, from: jsonData)
            ConfigHelper.username = decodedData.username
            print("got config: \(decodedData.username)")
        }catch{
            print(error)
        }
    }
    
    
    
}
