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
    
    var note: String = ""
    var noteTitle: String = ""
    var noteIndexPath: Int = 0
    
    var newNote: Bool = false
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var letterTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        titleTextView.text = noteTitle
        letterTextView.text = note
        letterTextView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 10)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = delegate.persistentContainer.viewContext
        
        if (newNote) {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
            
            if titleTextView.text != "" {
                let note = NSManagedObject(entity: entity, insertInto: context)
                
                note.setValue(titleTextView.text, forKey: "title")
                note.setValue(letterTextView.text, forKey: "text")
                note.setValue(Helper.sharedInstance.getCurrentTime(), forKey: "dateCreated")
//
//                if (!passwordTextField.isHidden) {
//                    note.setValue(passwordTextField.text, forKey: "password")
//                } else {
//                    note.setValue(nil, forKey: "password")
//                }
                
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Failed to add note. Error: \(error)")
                }
                
                navigationController?.popViewController(animated: true)
            } else {
                let alertController = UIAlertController(title: "No Title", message: "Please enter a title. It cannot be empty!", preferredStyle: UIAlertControllerStyle.alert)
                let okaction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okaction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        } else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            
            do {
                let results = try context.fetch(fetchRequest)
                
                results[noteIndexPath].setValue(letterTextView.text, forKey: "text")
                try context.save()
            } catch let error as NSError {
                print("Fetch notes failed. Error: \(error)")
            }
        }
    }
    
}
