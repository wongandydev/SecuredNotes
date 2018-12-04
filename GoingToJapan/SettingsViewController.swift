//
//  SettingsViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 12/2/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    func configureCell(text: String) {
        self.textLabel?.text = text
        self.textLabel?.textColor = Theme.changeTextToTheme()
        self.backgroundColor = .clear
    }
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var settingTableView: UITableView!
    
    var headers = ["Themes", "Test 2", "Test 3"]
    var cells = [["Light", "Dark"], ["1", "2"], ["3", "4"]]
    
    override func viewDidLoad() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as? SettingsCell {
            cell.configureCell(text: cells[indexPath.section][indexPath.row])
            return cell
        } else {
            return SettingsCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = cells[indexPath.section][indexPath.row]
        
        if title == "Light" {
            Theme.setTheme(themeType: "Light")
        } else if title == "Dark" {
            Theme.setTheme(themeType: "Dark")
        }
        
        settingTableView.deselectRow(at: indexPath, animated: true)
        Theme.applyTheme()
        
        if UserDefaults.standard.value(forKey: "selectedTheme") as? String == "Dark"{
            self.navigationController?.navigationBar.barStyle = UIBarStyle.black
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        } else {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.default
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        }
    }
}
