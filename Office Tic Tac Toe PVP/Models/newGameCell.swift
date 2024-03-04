//
//  newGameCell.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit
import FirebaseAuth

class newGameCell: UITableViewCell {
    
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    var currentIndex:Int?
    
    var friendUsername:String?
    var friendImage:String?
    var friendUID:String?
    
    
    var sendInvite: ((Int) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func invite(_ sender: UIButton) {
        print("THE CURRENT INDEX IS: \(currentIndex)")
        sendInvite?(currentIndex!)
        
        authService.shared.getUser { user, error in
            if let error = error{
                print("Error getting users: \(error.localizedDescription)")
            }
            
            if let user = user {
                let userData = newUser(image: user.profileImage, name: user.username, uid: Auth.auth().currentUser?.uid)
                let friends = friendInfo(username: self.friendUsername, profileImage: self.friendImage, uid: self.friendUID)
                authService.shared.sendGameInvite(friends, userData) { error in
                    if let error = error {
                        print("Error sending game invite \(error.localizedDescription)")
                    }else{
                        print("game invite sent succesfully")
                    }
                }
            }
        }
     
        
    }
    

}
