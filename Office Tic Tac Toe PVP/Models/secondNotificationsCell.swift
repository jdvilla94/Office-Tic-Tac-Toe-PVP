//
//  secondNotificationsCell.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class secondNotificationsCell: UITableViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    
    
    var imageString: String?
    
    var uid:String?
    var currentIndex:Int?
    //callback closure for simplicity. instead of delegate
//    var acceptButtonAction: ((Int, Bool) -> Void)?
    var acceptButtonAction: ((Int, Bool,String) -> Void)?
    
    var ignoreButtonAction: ((Int) -> Void)?
    
    
    var mainUsername:String?
    var mainImageString:String?
    var mainUID:String?
    
    var gameID: String?
    private var gameAcceptanceListener: ListenerRegistration?

    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func accept(_ sender: UIButton) {
        // Immediately remove data from the arrays and update the table view
//        self.acceptButtonAction?(currentIndex!,true,gameID!)
    
        // Call the callback closure when the accept button is tapped
        authService.shared.updateGameInviteAcceptedStatus(userUID: Auth.auth().currentUser!.uid, friendUID: self.uid!, didAccept: true) { error in
            print("did we get this far?")
                if let error = error {
                    print("Error updating game invite status: \(error.localizedDescription)")
                } else {
                    print("Game invite status updated successfully.")
                    print("everything works and we accepted the game, and we should be in the gameboard")
                    self.startGameAcceptanceListener()
                    
                    }
                }
        
        
        
            
            }
    
    
    private func startGameAcceptanceListener() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user authenticated.")
            return
        }

        print("the current user in load is: \(userUID)")

        let db = Firestore.firestore()

        // Reference to the document where the game acceptance status is stored
        let gameStatusRef = db.collection("allUsers").document(userUID)

        print("Starting game acceptance listener.")

        gameAcceptanceListener = gameStatusRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            
                if let documentData = documentSnapshot?.data() {
//                    print("Document Data: \(documentData)")

                    // Access the "Game Invites Sent" field
                    if let gameInvitesSent = documentData["Game Invites Recieved"] as? [String: Any],
                       let firstGameInvite = gameInvitesSent["0"] as? [String: Any],
                       let gameAccepted = firstGameInvite["didAccept"] as? Bool,
                       let gameID = firstGameInvite["gameID"] as? String {
                        self.acceptButtonAction?(self.currentIndex!,true,gameID)
                        DispatchQueue.main.async {
                            self.gameID = gameID
//                            self.didAccept = gameAccepted
                        }
                        print("The game id in database of noti is: \(gameID)")

//                        if gameAccepted == true {
//                            self.player2GameID = gameID
//                            self.didAccept = gameAccepted
////                            self.player2GameID = gameID
////                            print("player2 game id is: \(self.player2GameID)")
////                            print("Game acceptance status updated. didAccept = \(gameAccepted)")
////                            self.performSegue(withIdentifier: "notiToGameboard", sender: nil)
//                        } else {
//                            print("They said false")
//                        }
                        self.stopGameAcceptanceListener()
                    } else {
                        print("didAccept field not found in the document.")
                    }
                } else {
                    print("Document is empty.")
                }
            
        }
    }

    
    private func stopGameAcceptanceListener() {
        // Stop the listener when needed (e.g., when the view controller is being deallocated)
        gameAcceptanceListener?.remove()
        print("We removed the listener")
    }
    
    @IBAction func ignore(_ sender: UIButton) {
        self.ignoreButtonAction?(currentIndex!)
    }
    
}
