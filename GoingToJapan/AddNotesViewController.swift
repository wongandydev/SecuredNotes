//
//  AddNotesViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 9/17/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddNotesViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var securedSwitch: UISwitch!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func didSelectSecureSwitch(_ sender: Any) {
        if securedSwitch.isOn {
            passwordTextField.isHidden = false
        } else {
            passwordTextField.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.layer.borderWidth = 2.0
        noteTextField.layer.borderWidth = 2.0
        passwordTextField.layer.borderWidth = 2.0
        securedSwitch.isOn = false
        passwordTextField.isHidden = true
        
        titleTextField.delegate = self
        noteTextField.delegate = self
        passwordTextField.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(processNote(sender:)))
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        noteTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    @objc func processNote(sender: UIBarButtonItem) {
        print(titleTextField.text)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Didn't get delegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
        
        let note = NSManagedObject(entity: entity, insertInto: context)
        
        note.setValue(titleTextField.text, forKey: "title")
        note.setValue(noteTextField.text, forKey: "text")
        
        if (!passwordTextField.isHidden) {
            note.setValue(passwordTextField.text, forKey: "password")
        } else {
            note.setValue(nil, forKey: "password")
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Failed to add note. Error: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
}
