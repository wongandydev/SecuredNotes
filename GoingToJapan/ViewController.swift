//
//  ViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import CoreData 
import UserNotifications

class DayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    var passwordEntered: Bool = false
}

class DaysViewController: UIViewController {

    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    var daysArr: [DayPassObject] = [] {
        didSet {
            self.daysCollectionView.reloadData()
        }
    }
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        daysCollectionView.backgroundColor = .lightPink
        
        self.view.backgroundColor = .lightPink
        self.navigationItem.title = "SecuredNotes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
//        daysArr = FakeAPIManager.sharedInstance.readJSON()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        var newArr: [DayPassObject] = []
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for data in results {
                let title = data.value(forKey: "title") as! String
                let text = data.value(forKey: "text") as! String
                print("Date Created: \(data.value(forKey: "dateCreated"))")
                
                if (data.value(forKey: "password") != nil) {
                    let password = data.value(forKey: "password") as! String
                    newArr.append(DayPassObject(date: title, password: password, letter: text))
                } else {
                    newArr.append(DayPassObject(date: title, letter: text))
                }
            }
        } catch let error as NSError {
            print("Fetch notes failed. Error: \(error)")
        }
        
        if daysArr != newArr {
            daysArr = newArr
        }
    }
    
    @objc func addNote() {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddNotesViewController") as? AddNotesViewController
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
}

extension DaysViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DayCollectionViewCell
        if daysArr[indexPath.row].password != "" {
            if cell.passwordEntered {
                authorizeUser(enteredPassword: "alreadyEntered", password: daysArr[indexPath.row].password, indexPath: indexPath)
            } else {
                loginMessage(title: "Login" , message: "Enter the password please.", login: true, password: daysArr[indexPath.row].password, indexPath: indexPath)
            }
        } else {
            authorizeUser(enteredPassword: "nilPassword", password: daysArr[indexPath.row].password, indexPath: indexPath)
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
        
        return cell
    }
}

extension DaysViewController {
    func authorizeUser(enteredPassword: String, password: String, indexPath: IndexPath) {
        let dvc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        dvc.letter = daysArr[indexPath.row].letter
        dvc.navigationItem.title = daysArr[indexPath.row].date
        if enteredPassword == password {
            self.navigationController?.pushViewController(dvc, animated: true)
            let cell = daysCollectionView.cellForItem(at: indexPath) as! DayCollectionViewCell
            cell.passwordEntered = true
            loginMessage(title: "Access Granted", message: "You Entered the Right Password", login: false)
        } else if enteredPassword == "alreadyEntered" {
            self.navigationController?.pushViewController(dvc, animated: true)
        } else if enteredPassword == "nilPassword" {
            self.navigationController?.pushViewController(dvc, animated: true)
        }
        else {
            loginMessage(title: "Wrong Password", message: "You entered the wrong password.", login: false)
        }
    }
    
    func loginMessage(title: String, message: String, login: Bool, password: String = "", indexPath: IndexPath = []) {
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
