//
//  PasswordViewController.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/28/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class passwordCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var passwordLabel: UILabel!
}

class PasswordViewController: UIViewController {
    
    var passwordArr: [DayPassObject] = []
    var popup:UIView!
    
    @IBOutlet weak var passwordCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordCollectionView.delegate = self
        passwordCollectionView.dataSource = self
        passwordCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        passwordCollectionView.backgroundColor = .mintGreen
        
        self.view.backgroundColor = .mintGreen
        
        self.navigationItem.title = "Passwords"
        
        passwordArr = FakeAPIManager.sharedInstance.readJSON()
    }
}

extension PasswordViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! passwordCollectionViewCell
        UIPasteboard.general.string = cell.passwordLabel.text
        showCopiedAlert()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 25, height: 50)
    }
}

extension PasswordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passwordArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "passwordCell", for: indexPath) as! passwordCollectionViewCell
        cell.passwordLabel.text = passwordArr[indexPath.row].password
        cell.passwordLabel.isOpaque = true
        cell.backgroundColor = .lightPink
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
}

extension PasswordViewController {
    
    func showCopiedAlert() {
        popup = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 120, height: 100)))
        popup.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        popup.backgroundColor = .pastelPurple
        popup.layer.cornerRadius = 5
        
        let label = UILabel(frame: CGRect(origin: self.view.frame.origin, size: CGSize(width: 120, height: 40)))
        label.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height / 2);
        label.text = "Copied"
        label.textAlignment = .center
        label.textColor = .white
        
        popup.addSubview(label)
        
        
        // show on screen
        self.view.addSubview(popup)
        
        // set the timer
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert(){
        if popup != nil { // Dismiss the view from here
            popup.removeFromSuperview()
        }
    }
}
