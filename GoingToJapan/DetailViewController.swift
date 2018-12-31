//
//  DetailViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class DetailViewController: UIViewController {
    
    var noteTitle: String = ""
    var note: String = ""
    var password: String = ""
    var noteIndexPath: Int = 0
    var isNewNote: Bool = false
    var willDeleteNote: Bool = false
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var letterTextView: UITextView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    var ref: DatabaseReference!
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Note?", message: "Are you sure you want to delete this note? Click 'Delete' to confirm. ", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ in
            self.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func passwordButtonTapped(_ sender: Any) {
        self.securedAlertMessage(title: "Set/Change Password?", message: "Please enter a password for the note.")
        //So we are going to try and set a message to aloow users to add password. After changing the view of adding and editing notes to the same view controller, we removed the password functionaltiy
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterTextView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 10)
        addKeyboardDoneButton()
        
        ref = Database.database().reference()
        
        if isNewNote {
            deleteButton.isEnabled = false
            deleteButton.tintColor = .clear
        } else {
            deleteButton.isEnabled = true
            deleteButton.tintColor = nil
        }
        
        titleTextView.delegate = self
        letterTextView.delegate = self
        
        titleTextView.textColor = noteTitle == "" ? .gray:.black
        letterTextView.textColor = note == "" ? .gray:.black
        
        titleTextView.text = noteTitle == "" ? "Title":noteTitle
        letterTextView.text = note == "" ? "Note":note
    }
    
    func addKeyboardDoneButton() {
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        titleTextView.inputAccessoryView = toolbar
        letterTextView.inputAccessoryView =  toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func addNote(entityName: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        if titleTextView.text != "Title" && titleTextView.text != "" || letterTextView.text != "Note" && letterTextView.text != ""{
            let note = NSManagedObject(entity: entity, insertInto: context)
            
            note.setValue(ref.childByAutoId().key, forKey: "uid")
            note.setValue(titleTextView.text == "Title" ? "No title" : titleTextView.text, forKey: "title")
            note.setValue(letterTextView.text, forKey: "note")
            note.setValue(Helper.sharedInstance.getCurrentTime(), forKey: "dateCreated")
            
            if password != "" {
                note.setValue(password, forKey: "password")
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Failed to add note. Error: \(error)")
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            print("note was empty. User decided not to continue creating a new note")
        }
    }
    
    func deleteNote() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            context.delete(results[noteIndexPath])
            try context.save()
            willDeleteNote = true
        } catch let error as NSError {
            print("Fetch notes failed. Error: \(error)")
        }
    }
    
    func securedAlertMessage(title: String, message: String) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = false
        })
        
        alertController.addAction(UIAlertAction(title: "Set Password", style: .default, handler: { buttonTapped in
            if let enteredPassword = alertController.textFields?.first?.text {
                self.password = enteredPassword
            }
            blurView.removeFromSuperview()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            blurView.removeFromSuperview()
        }))
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        if isNewNote {
            addNote(entityName: "Note", context: context)
        } else if willDeleteNote {
            
        } else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            
            do {
                let results = try context.fetch(fetchRequest)
                
                results[noteIndexPath].setValue(letterTextView.text, forKey: "note")
                results[noteIndexPath].setValue(titleTextView.text, forKey: "title")
                results[noteIndexPath].setValue(password, forKey: "password")
                
                if letterTextView.text != note || titleTextView.text != noteTitle {
                    results[noteIndexPath].setValue(Helper.sharedInstance.getCurrentTime(), forKey: "dateModified")
                }
                
                try context.save()
            } catch let error as NSError {
                print("Fetch notes failed. Error: \(error)")
            }
        }
    }
    
    
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if titleTextView.text == "" {
            titleTextView.text = "Title"
            titleTextView.textColor = .gray
        }
        
        if letterTextView.text == "" {
            letterTextView.text = "Note"
            letterTextView.textColor = .gray
        }
    }
}
