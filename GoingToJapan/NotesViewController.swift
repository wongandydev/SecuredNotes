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
import Firebase

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var passwordEntered: Bool = false
}

class NotesViewController: UIViewController {

    @IBOutlet weak var daysCollectionView: UICollectionView!
    let userUID = UIDevice.current.identifierForVendor?.uuidString
    
    var firebaseDatabase: DatabaseReference!
    
    var daysArr: [Notes] = [] {
        didSet {
            self.daysCollectionView.reloadData()
        }
    }
    
    private let refreshControl = UIRefreshControl()

    let firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseDatabase = Database.database().reference()
        
        Theme.applyTheme()
        setUID()
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.refreshControl = refreshControl
        daysCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        daysCollectionView.backgroundColor = .lightPink
        
        refreshControl.addTarget(self, action: #selector(refreshNotes(_:)), for: .valueChanged)
        
        self.view.backgroundColor = .lightPink
        self.navigationItem.title = "SecuredNotes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }
    
    @objc private func refreshNotes(_ sender: Any) {
        getNotes()
        
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNotes()
    }
    
    func setUID(){
        if UserDefaults.isFirstLaunch() {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = delegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
            
            let user = NSManagedObject(entity: entity, insertInto: context)
            user.setValue(userUID, forKey: "uid")
        } else {
            print("not first launch"
            )
        }
    }
    
    func getNotes(){
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        var newArr: [Notes] = []
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for data in results {
                let uid = data.value(forKey: "uid") as! String
                let title = data.value(forKey: "title") as! String
                let note = data.value(forKey: "note") as! String
                let dateCreated = Helper.sharedInstance.dateToString(date: data.value(forKey: "dateCreated") as! Date)
                let dateModified = (data.value(forKey: "dateModified") as? Date) == nil ? "" : Helper.sharedInstance.dateToString(date: data.value(forKey: "dateModified") as! Date)
            
                if (data.value(forKey: "password") != nil) {
                    let password = data.value(forKey: "password") as! String
                    newArr.append(Notes(uid: uid, dateCreated: dateCreated, dateModified: dateModified, password: password, note: note, title: title))
                } else {
                    newArr.append(Notes(uid: uid, dateCreated: dateCreated, dateModified: dateModified, note: note, title: title))
                }
            }
        } catch let error as NSError {
            print("Fetch notes failed. Error: \(error)")
        }
        
        if (daysArr != newArr) {
            daysArr = newArr
            
            for i in newArr {
                self.firebaseDatabase.child("notes/\(i.uid)").setValue(["title": i.title, "note": i.note, "dateModified": i.dateModified, "password": i.password, "dateCreated": i.dateCreated])
                self.firebaseDatabase.child("users/\(userUID!)/notes/\(i.uid)").setValue(["title": i.title, "note": i.note, "dateModified": i.dateModified, "password": i.password, "dateCreated": i.dateCreated])
            }
        }
    }
    
    @objc func addNote() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        viewController.isNewNote = true
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        return CGSize(width: collectionView.bounds.width - 25, height: 60)
    }
    
}

extension NotesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCollectionViewCell
        
        cell.titleLabel.text = daysArr[indexPath.row].title
        
        if daysArr[indexPath.row].dateModified == "" {
            cell.dateLabel.text = daysArr[indexPath.row].dateCreated
        } else {
            cell.dateLabel.text = daysArr[indexPath.row].dateModified
        }
        
        cell.backgroundColor = .mintGreen
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
}

extension NotesViewController {
    func authorizeUser(enteredPassword: String, password: String, indexPath: IndexPath) {
        let dvc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        dvc.note = daysArr[indexPath.row].note
        dvc.noteIndexPath = indexPath.row
        dvc.noteTitle = daysArr[indexPath.row].title
        dvc.password = daysArr[indexPath.row].password
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

extension UserDefaults {
    static func isFirstLaunch() -> Bool{
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasBeenLaunched")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
            UserDefaults.standard.synchronize()
        }
        
        return isFirstLaunch
    }
}
