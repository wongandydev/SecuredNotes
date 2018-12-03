//
//  Theme.swift
//  GoingToJapan
//
//  Created by Andy Wong on 12/2/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

struct Theme{
    
    static var themeType: String = "Light"
    
    static func light(){
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = UIColor(red: 0.0, green: 122.0/255, blue: 1.0, alpha: 1.0)
        
        UINavigationBar.appearance().barStyle = UIBarStyle.default
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        //UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().barStyle = UIBarStyle.default
        UITabBar.appearance().barTintColor = UIColor.white
        
        UITextField.appearance().backgroundColor = UIColor.clear
        UITextView.appearance().backgroundColor = UIColor.clear
        
        UITableView.appearance().backgroundColor = UIColor.white
        UITableViewCell.appearance().textLabel?.textColor = UIColor.black
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = UIColor.black
        UILabel.appearance().textColor = UIColor.black

    }
    
    static func dark(){
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = UIColor.white
        
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().backgroundColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //UINavigationBar.appearance().isTranslucent = false
        
//        UITabBar.appearance().barStyle = UIBarStyle.black
        UITabBar.appearance().barTintColor = UIColor.black
        
        UITextField.appearance().backgroundColor = UIColor.clear
        UITextView.appearance().backgroundColor = UIColor.clear
        
        UITableView.appearance().backgroundColor = UIColor.black
        UITableViewCell.appearance().textLabel?.textColor = UIColor.white
        UITableViewCell.appearance().backgroundColor = UIColor.clear

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = UIColor.white
        UILabel.appearance().textColor = UIColor.white
        
    }
    
    static func changeTextToTheme() -> UIColor{
        let theme = UserDefaults.standard.value(forKey: "selectedTheme") as? String
        
        if theme == "Dark"{
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    static func setTheme(themeType: String){
        UserDefaults.standard.set(themeType, forKey: "selectedTheme")
        UserDefaults.standard.synchronize()
        
        if themeType == "Light" {
            self.themeType = themeType
        }
        else if themeType == "Dark" {
            self.themeType = themeType
        }
        else {
            self.themeType = "Light"
        }
    }
    
    static func applyTheme(){
        if let storedTheme = UserDefaults.standard.value(forKey: "selectedTheme") as? String{
            if storedTheme == "Light"{
                return light()
            }
            else if storedTheme == "Dark" {
                return dark()
            }
            else {
                return light()
            }
        }
    }
}
