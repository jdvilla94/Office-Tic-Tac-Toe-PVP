//
//  notificationsCell.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/12/24.
//

import UIKit
import FirebaseAuth

class notificationsCell: UITableViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    var imageString: String?
    
    var uid:String?
    var currentIndex:Int?
    //callback closure for simplicity. instead of delegate
    var acceptButtonAction: ((Int) -> Void)?
   
    
    var ignoreButtonAction: ((Int) -> Void)?
    
    
    var mainUsername:String?
    var mainImageString:String?
    var mainUID:String?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("The image string is: \(imageString)")
    }
    
    

    @IBAction func accept(_ sender: UIButton) {
//        print("The username is \(username.text) the uid is: \(uid) and the image is: \(imageString) ")
//        print("The current index is: \(currentIndex)")
        let friend = friendInfo(username: username.text, profileImage: imageString, uid: uid)
        
        let user = newUser(image: mainImageString, name: mainUsername, uid: mainUID)
        
        // Immediately remove data from the arrays and update the table view
        self.acceptButtonAction?(currentIndex!)
        
        authService.shared.acceptFriendRequest(friend, user) { [weak self] error in
            if let error = error {
                print("Error accepting friend request: \(error.localizedDescription)")
            } else {
                print("Friend request accepted")
                // Call the callback closure when the accept button is tapped
                authService.shared.updateGameInviteAcceptedStatus(userUID: Auth.auth().currentUser!.uid, friendUID: self!.uid!, didAccept: true) { error in
                    print("did we get this far?")
                    if let error = error {
                        print("Error updating game invite status: \(error.localizedDescription)")
                    } else {
                        print("Game invite status updated successfully.")
        
                    }
                }
            }
        }
        
    
        
       
    }
    
    
    @IBAction func ignore(_ sender: UIButton) {
        authService.shared.removeRequestsFromFirebase(index: currentIndex!)
        self.ignoreButtonAction?(currentIndex!)
    }
    
    
    

}
