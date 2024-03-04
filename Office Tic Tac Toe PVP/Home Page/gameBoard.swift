//
//  gameBoard.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class gameBoard: UIViewController {
    
    var player1ImageString:String?
    var player1UID:String?
    var player1Username:String?
    @IBOutlet var player1Name: UILabel!
    @IBOutlet var player1Image: UIImageView!
    
    var player2ImageString: String?
    var player2UID:String?
    var player2Username:String?
    @IBOutlet var player2Name: UILabel!
    @IBOutlet var player2Image: UIImageView!
    
    var player1GameID: String?
    var player2GameID: String?

    var didAccept:Bool?
    var didUpdateStatus = false
    
    private var gameAcceptanceListener: ListenerRegistration?
    var gameID: String?
    var currentPlayer: String?
    var player1Turn:Bool?
    var player2Turn :Bool?
    var gameArray = Array(repeating: 0, count: 9)
    
    @IBOutlet var gameButtons: [UIButton]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("The gameArray is: \(gameArray)")
        // Do any additional setup after loading the view.
        print("GAME BOARD PLAYER 2 game id: \(player2GameID)")
        print("-------")
        print("GAME BOARD PLAYER 1 game id: \(player1GameID)")

        let (player1Image, player2Image) = authService.shared.pickTwoRandomImages()
        
        if let player1GameID = player1GameID, !player1GameID.isEmpty {
            // Use player1GameID if it's not nil and not empty
            print("WE ARE IN THE PLAYER1 GAME ID")
            gameID = player1GameID
            currentPlayer = "Player 1"
//            authService.shared.updateCurrentPlayer(forGameID: gameID!, currentPlayer: "Player 1",player1Turn: true,player2Turn: false) { error in
//                if let error = error {
//                    print("Error updating current player: \(error.localizedDescription)")
//                } else {
//                    print("Current player updated successfully")
//                }
//            }
            print("THE GAME ID player1 IN THE BOARD IS: \(gameID)")
        } else if let player2GameID = player2GameID, !player2GameID.isEmpty,didAccept == true {
            // Use player2GameID if it's not nil and not empty
            print("WE ARE IN THE PLAYER2 GAME ID")
            gameID = player2GameID
            currentPlayer = "Player 2"
//            authService.shared.updateCurrentPlayer(forGameID: gameID!, currentPlayer: "Player 2",player1Turn: false,player2Turn: true) { error in
//                if let error = error {
//                    print("Error updating current player: \(error.localizedDescription)")
//                } else {
//                    print("Current player updated successfully")
//                }
//            }
            print("THE GAME ID player2 IN THE BOARD IS: \(gameID)")
        } else {
            // Handle the case where both player1GameID and player2GameID are nil or empty
            print("Both player1GameID and player2GameID are nil or empty.")
            return
        }
        
        
        
        print("THE GAME ID IN THE BOARD IS: \(gameID)")
        authService.shared.getPlayersForGameID(gameID!) { [self] player1UID, player2UID, error in
            if let error = error {
                // Handle the error
                print("Error retrieving players for gameID: \(error.localizedDescription)")
            } else {
                // Use player1UID and player2UID as needed
                if let player1UID = player1UID, let player2UID = player2UID {
                    print("Player 1 UID: \(player1UID)")
                    print("Player 2 UID: \(player2UID)")

                    authService.shared.getUser { user, error in
                        if let error = error {
                            print("There was an error retrieving user: \(error.localizedDescription)")
                        }

                        if let user = user {
                            DispatchQueue.main.async {
                                if Auth.auth().currentUser?.uid == player1UID {
                                    self.player1Name.text = user.username
                                    authService.shared.downloadImage(from: user.profileImage) { image, error in
                                        if officeImages.pics.keys.contains(user.profileImage) {
                                            self.player1Image.image = officeImages.pics[user.profileImage]
                                        } else {
                                            self.player1Image.image = image
                                        }
                                    }
                                } else if Auth.auth().currentUser?.uid == player2UID {
                                    self.player2Name.text = user.username
                                    authService.shared.downloadImage(from: user.profileImage) { image, error in
                                        if officeImages.pics.keys.contains(user.profileImage) {
                                            self.player2Image.image = officeImages.pics[user.profileImage]
                                        } else {
                                            self.player2Image.image = image
                                        }
                                    }
                                }

                                authService.shared.getOtherUser(Auth.auth().currentUser?.uid == player1UID ? player2UID : player1UID) { otherUser, error in
                                    if let error = error {
                                        print("Could not get the other user: \(error.localizedDescription)")
                                    }

                                    if let otherUser = otherUser {
                                        DispatchQueue.main.async {
                                            if Auth.auth().currentUser?.uid == player1UID {
                                                self.player2Name.text = otherUser.username
                                                authService.shared.downloadImage(from: otherUser.profileImage) { image, error in
                                                    if officeImages.pics.keys.contains(otherUser.profileImage) {
                                                        self.player2Image.image = officeImages.pics[otherUser.profileImage]
                                                    } else {
                                                        self.player2Image.image = image
                                                    }
                                                }
                                            } else if Auth.auth().currentUser?.uid == player2UID {
                                                self.player1Name.text = otherUser.username
                                                authService.shared.downloadImage(from: otherUser.profileImage) { image, error in
                                                    if officeImages.pics.keys.contains(otherUser.profileImage) {
                                                        self.player1Image.image = officeImages.pics[otherUser.profileImage]
                                                    } else {
                                                        self.player1Image.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    authService.shared.updateCurrentPlayer(forGameID: gameID!, currentPlayer: Auth.auth().currentUser?.uid == player1UID ? "Player 1" : "Player 2", player1Turn: Auth.auth().currentUser?.uid == player1UID, player2Turn: Auth.auth().currentUser?.uid == player2UID) { error in
                        if let error = error {
                            print("Error updating current player: \(error.localizedDescription)")
                        } else {
                            print("Current player updated successfully")
                        }
                    }
                } else {
                    print("Player UID not found.")
                }
            }
        }






        
        startGameAcceptanceListener()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGameAcceptanceListener()
    }
    
    private func startGameAcceptanceListener() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user authenticated.")
            return
        }

        print("the current user in load is: \(userUID)")

        let db = Firestore.firestore()
        print("The gameID in the listener is.... \(gameID)")
        // Reference to the document where the game acceptance status is stored

        gameAcceptanceListener = db.collection("gameIDs")
            .document(gameID!)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting document: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("Document data was empty.")
                    return
                }

                if let moves = snapshot["allMoves"] as? [Int], moves != self.gameArray {
                    // Handle the updated moves array
                    print("Updated moves array in listener: \(moves)")
//                    DispatchQueue.main.async {
                        self.gameArray = moves
                        
                    self.updateUIImage()
                        
                        // Iterate over both moves and buttons
                        //batch ui update
//                        for (index, move) in moves.enumerated() {
//                            // Get the corresponding button based on index
//                            guard index < self.gameButtons.count else {
//                                print("Index out of bounds for buttons array.")
//                                return
//                            }
//                            
//                            
//                            
//                            // Update button's image based on the move
//                            DispatchQueue.main.async {
//                                let button = self.gameButtons[index]
//                                if move == 1 {
//                                    if let scaledImage = self.scaleImage(self.player1Image.image, toSize: CGSize(width: 50, height: 50)) {
//                                        button.imageView?.contentMode = .scaleAspectFit
//                                        button.setImage(scaledImage, for: .normal)
//                                    }
//                                } else if move == 2 {
//                                    if let scaledImage = self.scaleImage(self.player2Image.image, toSize: CGSize(width: 50, height: 50)) {
//                                        button.imageView?.contentMode = .scaleAspectFit
//                                        button.setImage(scaledImage, for: .normal)
//                                    }
//                                }
//                            }
//                        }
                }
                // Check for a winner after updating the UI for both players
                let winner = self.checkWinner()
                if winner != 0 {
                    self.showAlert()
                    print("Player \(winner) wins!")
                    // Perform any actions for a winner, such as displaying a message or resetting the game
                } else {
                    print("There is no winner yet")
                }
            }
    }


    
    func makeMove(at index: Int) {
        // Check if the spot is taken
        guard gameArray[index] == 0 else {
            print("That spot is taken, please choose a different one")
            return
        }

        
        authService.shared.getCurrentPlayer(forGameID: gameID!) { currentplayer,player1,player2, error in
            if let error = error {
                print("There was an error getting current plauyer: \(error.localizedDescription)")
            }
            
            if currentplayer == "Player 1" && player1 == true {
                self.gameArray[index] = 1
                DispatchQueue.main.async {
                    self.updateUIImage()
                    authService.shared.updatePlayerMoves(self.gameID!, playerMoves: self.gameArray) { [self] error, updateGameArray in
                        if let error = error {
                            print("Error updating the players moves: \(error.localizedDescription)")
                        } else if let updateGameArray = updateGameArray {
                            print("Player moves updated successfully. Updated game array: \(updateGameArray)")
                            authService.shared.updateCurrentPlayer(forGameID: gameID!, currentPlayer: "Player 2",player1Turn: false,player2Turn: true) { error in
                                if let error = error {
                                    print("Error updating current player: \(error.localizedDescription)")
                                } else {
                                    print("Current player updated successfully: \(currentplayer).")
                                }
                            }
                        }
      
                    }
                }
                
            }else if currentplayer == "Player 2" && player2 == true{
                self.gameArray[index] = 2
                DispatchQueue.main.async {
                    self.updateUIImage()
                    
                    authService.shared.updatePlayerMoves(self.gameID!, playerMoves: self.gameArray) { [self] error, updateGameArray in
                        if let error = error {
                            print("Error updating the players moves: \(error.localizedDescription)")
                        } else if let updateGameArray = updateGameArray {
                            print("Player moves updated successfully. Updated game array: \(updateGameArray)")
                            authService.shared.updateCurrentPlayer(forGameID: gameID!, currentPlayer: "Player 1",player1Turn: true,player2Turn: false) { error in
                                if let error = error {
                                    print("Error updating current player: \(error.localizedDescription)")
                                } else {
                                    print("Current player updated successfully: \(currentplayer).")
                                }
                            }
                        }

                        
                    }
                }
            }
        }
        // Check for a winner after the move

    }
    
    func updateUIImage() {
        for (index, move) in self.gameArray.enumerated() {
            // Get the corresponding button based on index
            guard index < self.gameButtons.count else {
                print("Index out of bounds for buttons array.")
                return
            }

            // Update button's image based on the move
            DispatchQueue.main.async {
                let button = self.gameButtons[index]
                if move == 1 {
                    self.updateButtonImage(button, with: self.player1Image.image)
                } else if move == 2 {
                    self.updateButtonImage(button, with: self.player2Image.image)
                } else {
                    button.setImage(nil, for: .normal)
                }
            }
        }
    }


//    
//    func updateUIImage() {
//        for (index, move) in self.gameArray.enumerated() {
//            // Get the corresponding button based on index
//            guard index < self.gameButtons.count else {
//                print("Index out of bounds for buttons array.")
//                return
//            }
//            
//            // Update button's image based on the move
//            DispatchQueue.main.async {
//                let button = self.gameButtons[index]
//                if move == 1 {
//                    self.updateButtonImage(button, with: self.player1Image.image)
//                } else if move == 2 {
//                    self.updateButtonImage(button, with: self.player2Image.image)
//                }
//                
//            }
//        }
//        
//    }

    
    func updateButtonImage(_ button: UIButton, with image: UIImage?) {
        if let scaledImage = self.scaleImage(image, toSize: CGSize(width: 50, height: 50)) {
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(scaledImage, for: .normal)
        }
    }
    
    func showAlert(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Winner", message: "Player _ has won!", preferredStyle: .alert)
            
            //add actions to alert controller
            let quitGame = UIAlertAction(title: "Quit Game", style: .destructive) { [weak self] _ in
                    // Handle quit action
                    self?.quitGame()
                }
            //add action to alert
            alertController.addAction(quitGame)
            self.present(alertController,animated: true,completion: nil)
        }
    }
    

    func quitGame() {
        // Check if the view controller is embedded in a navigation controller
        if let navigationController = navigationController {
            // Pop back to the root view controller (homepage)
            navigationController.popToRootViewController(animated: true)
        } else {
            // If not embedded in a navigation controller, you can present or push the homepage view controller as needed
            let homepageViewController = homePage()
            present(homepageViewController, animated: true, completion: nil)
        }
    }

    
    private func stopGameAcceptanceListener() {
        // Stop the listener when needed (e.g., when the view controller is being deallocated)
        gameAcceptanceListener?.remove()
        print("We removed the listener")
    }
    
    @IBAction func space0(_ sender: UIButton) {
        makeMove(at: 0)
        }
    
    @IBAction func space1(_ sender: UIButton) {
        makeMove(at: 1)
    }
    
    
    @IBAction func space2(_ sender: UIButton) {
        makeMove(at: 2)
    }
    
    @IBAction func space3(_ sender: UIButton) {
        makeMove(at: 3)
    }
    
    @IBAction func space4(_ sender: UIButton) {
        makeMove(at: 4)
    }
    
    @IBAction func space5(_ sender: UIButton) {
        makeMove(at: 5)
    }
    @IBAction func space6(_ sender: UIButton) {
        makeMove(at: 6)
    }
    @IBAction func space7(_ sender: UIButton) {
        makeMove(at: 7)
    }
    
    @IBAction func space8(_ sender: UIButton) {
        makeMove(at: 8)
    }

    func checkWinner() -> Int {
        // Define all possible winning combinations
        let winningCombos = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],  // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8],  // Columns
            [0, 4, 8], [2, 4, 6]               // Diagonals
        ]

        // Iterate through each winning combination ex.) [0,1,2] .. each has postion 0,1,2
        for combination in winningCombos{
            let firstPostition = combination[0]
            let secondPostition = combination[1]
            let thirdPostition = combination[2]

            // Check if all three positions in the combination are equal and not zero
            if gameArray[firstPostition] != 0 && gameArray[firstPostition] == gameArray[secondPostition] && gameArray[firstPostition] == gameArray[thirdPostition] {
                // Return the player number who won (1 or 2)
                return gameArray[firstPostition]
            }
        }

        // If no winner found
        return 0
    }

    
    // Function to scale the image to a specific size
    func scaleImage(_ image: UIImage?, toSize newSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    
    
    
    


}
