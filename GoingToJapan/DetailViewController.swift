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
    var noteIndexPath: Int = 0
    var isNewNote: Bool = false
    var willDeleteNote: Bool = false
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var letterTextView: UITextView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    var ref: DatabaseReference!
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "No Title", message: "Please enter a title. It cannot be empty!", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ in
            self.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterTextView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 10)
        
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
    
    func addNote(entityName: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        if titleTextView.text != "Title" && titleTextView.text != "" || letterTextView.text != "Note" && letterTextView.text != ""{
            let note = NSManagedObject(entity: entity, insertInto: context)
            
            note.setValue(ref.childByAutoId().key, forKey: "uid")
            note.setValue(titleTextView.text == "Title" ? "No title" : titleTextView.text, forKey: "title")
            note.setValue(letterTextView.text, forKey: "note")
            note.setValue(Helper.sharedInstance.getCurrentTime(), forKey: "dateCreated")
            
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
                results[noteIndexPath].setValue(Helper.sharedInstance.getCurrentTime(), forKey: "dateModified")
                
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
}
