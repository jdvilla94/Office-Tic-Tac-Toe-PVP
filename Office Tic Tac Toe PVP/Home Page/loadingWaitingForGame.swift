//
//  loadingWaitingForGame.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class loadingWaitingForGame: UIViewController {
    
    var imageString:String?
    var uid:String?
    var username:String?
    
    var player2ImageString: String?
    var player2UID:String?
    var player2Username:String?
    
    var player1GameID:String?
    
    var didAccept:Bool?
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileUsername: UILabel!
    @IBOutlet var statusButton: UIButton!
    
    // Firestore reference for the document that holds the game acceptance status
    private var gameAcceptanceListener: ListenerRegistration?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("the image string is: \(imageString)")
        print("the uid is: \(uid)")
        print("the username is: \(username)")
        
        authService.shared.downloadImage(from: self.imageString!) { image, error in
            if officeImages.pics.keys.contains(self.imageString!){
                self.profileImage.image = officeImages.pics[self.imageString!]
            }else{
                self.profileImage.image = image
            }
            
            DispatchQueue.main.async {
                self.profileUsername.text = self.username
            }
            
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startGameAcceptanceListener()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadingToGameboard"{
            let destVC = segue.destination as! gameBoard
            destVC.player2GameID = player1GameID
            destVC.didAccept = didAccept
            print("gameID in loading = \(player1GameID)")
            
//            destVC.player2Username = player2Username
//            destVC.player2ImageString = player2ImageString
//            destVC.player2UID = player2UID
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Deinitializing loadingWaitingForGame")
         stopGameAcceptanceListener()
    }
    

    
    private func startGameAcceptanceListener() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user authenticated.")
            return
        }
        
        print("the curren user in load is: \(userUID)")

        let db = Firestore.firestore()

        // Reference to the document where game acceptance status is stored
        let gameStatusRef = db.collection("allUsers").document(userUID)

        print("Starting game acceptance listener.")

        
        gameAcceptanceListener = gameStatusRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let documentData = documentSnapshot?.data() {
                print("Document Data: \(documentData)")

                // Access the "Game Invites Sent" field
                if let gameInvitesSent = documentData["Game Invites Sent"] as? [String: Any],
                   let firstGameInvite = gameInvitesSent["0"] as? [String: Any],
                   let gameAccepted = firstGameInvite["didAccept"] as? Bool,
                   let gameID = firstGameInvite["gameID"] as? String{
                    self.player1GameID = gameID
                    self.didAccept = gameAccepted
                    print("The game id in database of loading is: \(gameID)")
//                    print("player1 game uid is: \(self.player1GameID)")
//                    print("Game acceptance status updated. didAccept = \(gameAccepted)")
                    if gameAccepted == true{
                        self.performSegue(withIdentifier: "loadingToGameboard", sender: nil)
                        
                    }else{
                        print("They said false")
                    }
                   
                    // The game has been accepted, perform the necessary actions
                    // self.navigateToNextViewController()
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
    
}
