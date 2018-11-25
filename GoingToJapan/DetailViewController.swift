//
//  DetailViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var noteTitle: String = ""
    var letter: String = ""
    var noteIndexPath: Int = 0
    var newNote: Bool = false
    var deleteNote: Bool = false
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var letterTextView: UITextView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        do {
            let results = try context.fetch(fetchRequest)
            print("before: \(results)")
            
            context.delete(results[noteIndexPath])
            try context.save()
            deleteNote = true
        } catch let error as NSError {
            print("Fetch notes failed. Error: \(error)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterTextView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 10)
        
        self.view.backgroundColor = .white
        
        if newNote {
            deleteButton.isEnabled = false
            deleteButton.tintColor = .clear
        } else {
            deleteButton.isEnabled = true
            deleteButton.tintColor = nil
        }
        
        titleTextView.delegate = self
        letterTextView.delegate = self
        
        titleTextView.textColor = noteTitle == "" ? .gray:.black
        letterTextView.textColor = letter == "" ? .gray:.black
        
        titleTextView.text = noteTitle == "" ? "Title":noteTitle
        letterTextView.text = letter == "" ? "Note":letter
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        if (newNote) {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
            
            if titleTextView.text != "Title" && titleTextView.text != "" || letterTextView.text != "Note" && letterTextView.text != ""{
                let note = NSManagedObject(entity: entity, insertInto: context)
                
                note.setValue(titleTextView.text == "Title" ? "No title" : titleTextView.text, forKey: "title")
                note.setValue(letterTextView.text, forKey: "text")
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
        } else if (deleteNote){
            
        } else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            
            do {
                let results = try context.fetch(fetchRequest)
                
                results[noteIndexPath].setValue(letterTextView.text, forKey: "text")
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
