//
//  searchNewfFriendsCell.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit
import FirebaseAuth

class searchNewfFriendsCell: UITableViewCell {
    
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    
    
    var uid:String?
    var imageString: String?
    
    @IBOutlet var addFriendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
    
    @IBAction func addFriend(_ sender: UIButton) {
        print("The current UID is: \(uid)")
        print("The curent imageString is: \(imageString)")
        print("The current name is: \(username.text)")
        authService.shared.getUser { user, error in
            if let error = error {
                print("Error getting user: \(error.localizedDescription)")
            }
            
            if let user = user{
                let friends = friendInfo(username: user.username, profileImage: user.profileImage, uid: self.uid)
                authService.shared.addFriend(friends) { error in
                    if let error = error {
                           print("Error sending friend request: \(error.localizedDescription)")
                       } else {
                           print("Friend request sent successfully.")
                       }
                }
            }
        }
        
        let friends = friendInfo(username: username.text, profileImage: imageString, uid: uid)
        authService.shared.sentRequest(friends) { error in
            if let error = error{
                print("Error putting sent request: \(error.localizedDescription)")
            }else{
                print("Sent requet was successfully put")
            }
        }
    
    }
    
    


}
