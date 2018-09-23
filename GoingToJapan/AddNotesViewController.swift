//
//  AddNotesViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 9/17/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import Foundation
import UIKit

class AddNotesViewController: UIViewController {
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(processNote(sender:)))
        
    }
    
    @objc func processNote(sender: UIBarButtonItem) {
        print(titleTextField.text)
        
        navigationController?.popViewController(animated: true)
    }
}
