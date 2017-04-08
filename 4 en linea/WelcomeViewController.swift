//
//  WelcomeViewController.swift
//  4 en linea
//
//  Created by f0go on 4/6/17.
//  Copyright © 2017 f0go. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var hint: UILabel!
    
    var new = true
    
    override func viewDidLoad() {
        key.text = randomString(length: 10)
        name.becomeFirstResponder()
    }
    
    @IBAction func play(_ sender: UIButton) {
        if name.text != "" && key.text != "" {
            let playView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            playView.key = key.text!
            playView.name = name.text!
            playView.new = new
            self.present(playView, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectGame(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            key.text = randomString(length: 10)
            new = true
            key.becomeFirstResponder()
            hint.text = "Copy and share key"
        }else {
            key.text = ""
            new = false
            key.becomeFirstResponder()
            hint.text = "Paste key"
        }
    }
    
    
    @IBAction func hideKeyboard(_ sender: UIButton) {
        key.resignFirstResponder()
        name.resignFirstResponder()
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
