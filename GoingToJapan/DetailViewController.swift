//
//  DetailViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var letter: String = ""
    var imagePath : String = ""
    
    @IBOutlet weak var letterTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterTextView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8)
        
        self.view.backgroundColor = .white
        letterTextView.text = letter
    
        photoImageView.image = UIImage(named: imagePath)
    }
}
