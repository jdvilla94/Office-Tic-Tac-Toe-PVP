//
//  newGame.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit

class newGame: UIViewController {
    
    var username: [String] = []
    var imageString: [String] = []
    var uids: [String] = []
    
    var player2ImageString: String?
    var player2UID:String?
    var player2Username:String?
    
    var curIndex:Int?

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        authService.shared.getFriends { friends, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let friends = friends {
                print("The requests are: \(friends)")
                for amigo in friends {
                    print("Name: \(amigo.username), Image: \(amigo.profileImage), UID: \(amigo.uid)")
                    self.username.append(amigo.username!)
                    self.imageString.append(amigo.profileImage!)
                    self.uids.append(amigo.uid!)
                    // Save or process the individual values as needed
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newgameToLoading" {
            let destVC = segue.destination as! loadingWaitingForGame
            destVC.username = username[curIndex!]
            destVC.imageString = imageString[curIndex!]
            destVC.uid = uids[curIndex!]
            destVC.player2Username = player2Username
            destVC.player2ImageString = player2ImageString
            destVC.player2UID = player2UID
        }
     
    }

}

extension newGame: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return username.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newGameCell", for: indexPath) as! newGameCell
        cell.username.text = username[indexPath.row]
        cell.currentIndex = indexPath.row
        
        cell.friendUsername = username[indexPath.row]
        cell.friendImage = imageString[indexPath.row]
        cell.friendUID = uids[indexPath.row]
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
        authService.shared.downloadImage(from: imageString[indexPath.row]) { image, error in
            if officeImages.pics.keys.contains(self.imageString[indexPath.row]){
                cell.profileImage.image = officeImages.pics[self.imageString[indexPath.row]]
            }else{
                cell.profileImage.image = image
            }

        }
        
        cell.sendInvite = { currentIndex in
            // Your code to handle the invitation
            print("Invitation sent!")
            self.curIndex = currentIndex
            print("the currnet index is: \(self.curIndex)")
            self.performSegue(withIdentifier: "newgameToLoading", sender: nil)
           
        }
        
        return cell
    }
}
