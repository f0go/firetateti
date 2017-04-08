//
//  ViewController.swift
//  4 en linea
//
//  Created by f0go on 4/2/17.
//  Copyright © 2017 f0go. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var loseWinLabel: UILabel!
    @IBOutlet weak var youLabel: UILabel!
    
    var cellStatus = ["","","","","","","","",""]
    let firebase = FIRDatabase.database().reference()
    var key = ""
    var name = ""
    var oponent = "opponent"
    var new: Bool!
    var turn = ""
    
    override func viewDidLoad() {
        collectionHeight.constant = view.bounds.width
        listenRemoteStatus()
        if new == false {
            loadGame()
        }else {
            createNewGame()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        
        if cellStatus[indexPath.row] == name {
            cell.indicator.text = "❌"
        }else if cellStatus[indexPath.row] == oponent {
            cell.indicator.text = "⭕️"
        }else {
            cell.indicator.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if turn == oponent {
            return
        }
        if loseWinLabel.isHidden == false {
            restartGame()
            return
        }
        
        if cellStatus[indexPath.row] == "" {
            cellStatus[indexPath.row] = name
            collection.reloadData()
            checkWin()
            updateRemoteStatus(load: false)
            return
        }
        
        var end = true
        for cell in cellStatus {
            if cell == "" {
                end = false
            }
        }
        if end == true {
            restartGame()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width / 3), height: (view.bounds.width / 3))
    }
    
    func updateRemoteStatus(load: Bool) {
        var player1 = oponent
        var player2 = name
        
        if new {
            player1 = name
            player2 = oponent
        }
        var aturn = oponent
        if load {
            aturn = name
        }
        
        let post = [
            "status":cellStatus,
            "name":player1,
            "oponent":player2,
            "turn":aturn
        ] as [String : Any]
        let childUpdates = [key: post]
        firebase.updateChildValues(childUpdates)
    }
    
    func listenRemoteStatus() {
        firebase.child(key).observe(FIRDataEventType.value, with: { (snapshot) in
            let snap = snapshot.value as? [String:Any]
            if snap == nil {
                self.dismiss(animated: true, completion: nil)
                return
            }
            if self.new {
                self.oponent = snap!["oponent"] as! String
            }else {
                self.oponent = snap!["name"] as! String
            }
            self.cellStatus = snap!["status"] as! [String]
            self.loseWinLabel.isHidden = true
            self.turn = snap!["turn"] as! String
            self.youLabel.text = self.turn.uppercased()
            self.collection.reloadData()
            self.checkWin()
        })
    }
    
    func loadGame() {
        firebase.child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let snap = snapshot.value as? [String:Any]
            if snap == nil {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.oponent = snap!["name"] as! String
            self.cellStatus = snap!["status"] as! [String]
            self.turn = snap!["turn"] as! String
            self.youLabel.text = self.turn.uppercased()
            self.collection.reloadData()
            self.updateRemoteStatus(load: true)
        })
    }
    
    func createNewGame() {
        let post = [
            "status":cellStatus,
            "name":name,
            "oponent":oponent,
            "turn":name
        ] as [String : Any]
        let childUpdates = [key: post]
        firebase.updateChildValues(childUpdates)
    }
    
    func restartGame() {
        cellStatus = ["","","","","","","","",""]
        loseWinLabel.isHidden = true
        updateRemoteStatus(load: true)
    }
    
    func checkWin() {
        if cellStatus[0] == name && cellStatus[1] == name && cellStatus[2] == name { // Linea Horizontal 1
            win()
        }else if cellStatus[0] == name && cellStatus[4] == name && cellStatus[8] == name { // Cruz 1
            win()
        }else if cellStatus[2] == name && cellStatus[4] == name && cellStatus[6] == name { // Cruz 2
            win()
        }else if cellStatus[3] == name && cellStatus[4] == name && cellStatus[5] == name { // Linea Horizontal 2
            win()
        }else if cellStatus[6] == name && cellStatus[7] == name && cellStatus[8] == name { // Linea Horizontal 3
            win()
        }else if cellStatus[0] == name && cellStatus[3] == name && cellStatus[6] == name { // Linea Vertical 1
            win()
        }else if cellStatus[1] == name && cellStatus[4] == name && cellStatus[7] == name { // Linea Vertical 2
            win()
        }else if cellStatus[2] == name && cellStatus[5] == name && cellStatus[8] == name { // Linea Vertical 3
            win()
        }else if cellStatus[0] == oponent && cellStatus[1] == oponent && cellStatus[2] == oponent { // Linea Horizontal 1
            lose()
        }else if cellStatus[0] == oponent && cellStatus[4] == oponent && cellStatus[8] == oponent { // Cruz 1
            lose()
        }else if cellStatus[2] == oponent && cellStatus[4] == oponent && cellStatus[6] == oponent { // Cruz 2
            lose()
        }else if cellStatus[3] == oponent && cellStatus[4] == oponent && cellStatus[5] == oponent { // Linea Horizontal 2
            lose()
        }else if cellStatus[6] == oponent && cellStatus[7] == oponent && cellStatus[8] == oponent { // Linea Horizontal 3
            lose()
        }else if cellStatus[0] == oponent && cellStatus[3] == oponent && cellStatus[6] == oponent { // Linea Vertical 1
            lose()
        }else if cellStatus[1] == oponent && cellStatus[4] == oponent && cellStatus[7] == oponent { // Linea Vertical 2
            lose()
        }else if cellStatus[2] == oponent && cellStatus[5] == oponent && cellStatus[8] == oponent { // Linea Vertical 3
            lose()
        }
    }
    
    func win() {
        loseWinLabel.text = "WIN 🏆"
        loseWinLabel.isHidden = false
        youLabel.text = "YOU"
    }
    
    func lose() {
        loseWinLabel.text = "LOSE 😕"
        loseWinLabel.isHidden = false
        youLabel.text = "YOU"
    }
}

