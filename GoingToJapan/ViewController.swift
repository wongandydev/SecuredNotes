//
//  ViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import UserNotifications

class DayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    var passwordEntered: Bool = false
}

class DaysViewController: UIViewController {

    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    var daysArr: [DayPassObject] = []
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificatons()
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        daysCollectionView.backgroundColor = .lightPink
        
        self.view.backgroundColor = .lightPink
        self.navigationItem.title = "Secure Notes"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: nil, action: nil)
        
        readJSON()
    }
    
    func setupNotificatons() {
            let notificationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: notificationOptions, completionHandler: { granted, error in
            if !granted {
                self.alertMessage(title: "No Notifications", message: "YOU DISABLE NOTIFCATIONS! TURN IT ON. Because THATS HOW YOU GET THE PASSWORDS", login: false)
            }
        })
    }
    
    /// Add notification to the notification center
    ///
    /// - Parameters:
    ///   - date: Date in string format that the notification should be sent
    ///   - body: the password that will be used to unlock the days, note
    ///   - identifier: a unique identifier for the specific notifcation.
    func addNotification(date: String, body: String, identifier: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy'T'hh:mm:ss a"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")

        let date = dateFormatter.date(from: date)
        print(date)

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Another Day, Another Note, Another Password"
        notificationContent.body = "Today's password is: \(body). Don't lose me!"
        notificationContent.sound = UNNotificationSound.default()

        let notificationDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger)
        
        notificationCenter.add(notificationRequest, withCompletionHandler: { error in
            print("Error: \(error)")
        })
    }
    
    func readJSON(){
        if let filePath = Bundle.main.path(forResource: "fakeData", ofType: "json") {
            do {
                let json = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
                let jsonResults = try JSONSerialization.jsonObject(with: json, options: .mutableLeaves)
                if let jsonResults = jsonResults as? [AnyObject] {
                    for result in jsonResults {
                        if let date = result["date"] as? String,
                            let password = result["password"] as? String,
                            let letter = result["letter"] as? String,
                            let imagePath = result["photoPath"] as? String{
                            daysArr.append(DayPassObject(date: date, password: password, letter: letter, imagePath: imagePath))
                            addNotification(date: "\(date)T9:00:00 AM", body: password, identifier: date)
                        }
                    }
                }
            } catch {
                
            }
        }
    }
}

extension DaysViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if stringToDate(date: daysArr[indexPath.row].date) >= Date() {
            alertMessage(title: "NOT TIME YET", message: "It's not time yet. This message has not been unlocked for you", login: false)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! DayCollectionViewCell
            if cell.passwordEntered {
                authorizeUser(enteredPassword: "alreadyEntered", password: daysArr[indexPath.row].password, indexPath: indexPath)
            } else {
                alertMessage(title: "Login" , message: "Enter the password please.", login: true, password: daysArr[indexPath.row].password, indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 25, height: 50)
    }
    
}

extension DaysViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCollectionViewCell
        
        cell.dayLabel.text = daysArr[indexPath.row].date
        cell.backgroundColor = .mintGreen
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        if stringToDate(date: daysArr[indexPath.row].date) >= Date() {
            cell.contentView.isHidden = true
        }
        
        return cell
    }
}

extension UIViewController {
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy'T'hh:mm:ss a"

        return dateFormatter.string(from: date)
    }

    func stringToDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        return dateFormatter.date(from: date)!
    }
}

extension DaysViewController {
    func authorizeUser(enteredPassword: String, password: String, indexPath: IndexPath) {
        let dvc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        dvc.letter = daysArr[indexPath.row].letter
        dvc.imagePath = daysArr[indexPath.row].imagePath
        dvc.navigationItem.title = daysArr[indexPath.row].date
        if enteredPassword == password {
            self.navigationController?.pushViewController(dvc, animated: true)
            let cell = daysCollectionView.cellForItem(at: indexPath) as! DayCollectionViewCell
            cell.passwordEntered = true
            alertMessage(title: "Access Granted", message: "You Entered the Right Password", login: false)
        } else if enteredPassword == "alreadyEntered" {
            self.navigationController?.pushViewController(dvc, animated: true)
        } else {
            alertMessage(title: "Wrong Password", message: "You entered the wrong password.", login: false)
        }
    }
    
    func alertMessage(title: String, message: String, login: Bool, password: String = "", indexPath: IndexPath = []) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if login {
            alertController.addTextField(configurationHandler: {(textField) in
                textField.placeholder = "Enter Password"
                textField.isSecureTextEntry = true
            })
            
            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { buttonTapped in
                if let enteredPassword = alertController.textFields?.first?.text {
                    self.authorizeUser(enteredPassword: enteredPassword, password: password, indexPath: indexPath)
                }
                blurView.removeFromSuperview()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                blurView.removeFromSuperview()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                blurView.removeFromSuperview()
            }))
        }
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
    }
}
