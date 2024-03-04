//
//  notifications.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class notifications: UIViewController {
    
    var username: [String] = []
    var imageString: [String] = []
    var uids: [String] = []
    
    
    var secondUsername: [String] = []
    var secondImageString: [String] = []
    var secondUIDS: [String] = []
    
    var mainUsername:String?
    var mainImageString:String?
    var mainUID:String?
    
    var currentIndex: Int?
    var didAccept:Bool?
    
//    // Firestore reference for the document that holds the game acceptance status
//    private var gameAcceptanceListener: ListenerRegistration?
    
    var player2GameID: String?
    
    @IBOutlet var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if username.isEmpty {
            authService.shared.getReceivedRequests { receivedRequests, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let receivedRequests = receivedRequests {
                    print("The requests are: \(receivedRequests)")
                    for request in receivedRequests {
                        print("Name: \(request.username), Image: \(request.profileImage), UID: \(request.uid)")
                        self.username.append(request.username!)
                        self.imageString.append(request.profileImage!)
                        self.uids.append(request.uid!)
                        // Save or process the individual values as needed
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
            
            authService.shared.getGameInvites { getInvite, error in
                if let error = error {
                    print("there was an error gettin gameInvite \(error.localizedDescription)")
                }
                
                if let getInvite = getInvite{
                    for invite in getInvite{
                        self.secondUsername.append(invite.username!)
                        self.secondImageString.append(invite.profileImage!)
                        self.secondUIDS.append(invite.uid!)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authService.shared.getUser { user, error in
            if let error = error {
                print("There was an error in getting favFoodandCity\(error)")
                return
            }
            DispatchQueue.main.async {
                if let user = user {
                    self.mainUsername = user.username
                    self.mainImageString = user.profileImage
                    self.mainUID = Auth.auth().currentUser?.uid
                }
            }
    
        }
        
//        startGameAcceptanceListener()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notiToGameboard" {
            let destVC = segue.destination as! gameBoard
            destVC.player1GameID = player2GameID
            destVC.didAccept = didAccept
            
            
            print("gameID in noti = \(player2GameID)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Deinitializing loadingWaitingForGame")
//         stopGameAcceptanceListener()
    }
    
//    private func startGameAcceptanceListener() {
//        guard let userUID = Auth.auth().currentUser?.uid else {
//            print("No user authenticated.")
//            return
//        }
//
//        print("the current user in load is: \(userUID)")
//
//        let db = Firestore.firestore()
//
//        // Reference to the document where the game acceptance status is stored
//        let gameStatusRef = db.collection("allUsers").document(userUID)
//
//        print("Starting game acceptance listener.")
//
//        gameAcceptanceListener = gameStatusRef.addSnapshotListener { documentSnapshot, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            
//                if let documentData = documentSnapshot?.data() {
////                    print("Document Data: \(documentData)")
//
//                    // Access the "Game Invites Sent" field
//                    if let gameInvitesSent = documentData["Game Invites Recieved"] as? [String: Any],
//                       let firstGameInvite = gameInvitesSent["0"] as? [String: Any],
//                       let gameAccepted = firstGameInvite["didAccept"] as? Bool,
//                       let gameID = firstGameInvite["gameID"] as? String {
//                        DispatchQueue.main.async {
//                            self.player2GameID = gameID
//                            self.didAccept = gameAccepted
//                        }
//                        print("The game id in database of noti is: \(gameID)")
//
////                        if gameAccepted == true {
////                            self.player2GameID = gameID
////                            self.didAccept = gameAccepted
//////                            self.player2GameID = gameID
//////                            print("player2 game id is: \(self.player2GameID)")
//////                            print("Game acceptance status updated. didAccept = \(gameAccepted)")
//////                            self.performSegue(withIdentifier: "notiToGameboard", sender: nil)
////                        } else {
////                            print("They said false")
////                        }
//                    } else {
//                        print("didAccept field not found in the document.")
//                    }
//                } else {
//                    print("Document is empty.")
//                }
//            
//        }
//    }
//
//    
//    private func stopGameAcceptanceListener() {
//        // Stop the listener when needed (e.g., when the view controller is being deallocated)
//        gameAcceptanceListener?.remove()
//        print("We removed the listener")
//    }
    

}

extension notifications: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
          return TableSection.allCases.count
      }
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          switch TableSection(rawValue: section) {
          case .section1:
              return username.count
          case .section2:
              return secondUsername.count
          case .none:
              return 0
          }
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          switch TableSection(rawValue: indexPath.section) {
          case .section1:
              let cell = tableView.dequeueReusableCell(withIdentifier: "notificationsCell", for: indexPath) as! notificationsCell
              cell.username.text = username[indexPath.row]
              cell.uid = uids[indexPath.row]
              cell.imageString = imageString[indexPath.row]
              cell.currentIndex = indexPath.row
              cell.acceptButtonAction = { [weak self] currentIndex in
                  // Use the currentIndex in your logic
                  print("Accept button tapped for index: \(currentIndex)")
                  // Reload the table view data if needed
                  self?.username.remove(at: currentIndex)
                  self?.imageString.remove(at: currentIndex)
                  self?.uids.remove(at: currentIndex)
                     
                  DispatchQueue.main.async {
                      self?.tableView.reloadData()
                  }
              }
              
              cell.ignoreButtonAction = { [weak self] currentIndex in
                  print("The ignore button was tapped")
                  self?.username.remove(at: currentIndex)
                  self?.imageString.remove(at: currentIndex)
                  self?.uids.remove(at: currentIndex)
                  DispatchQueue.main.async {
                      self?.tableView.reloadData()
                  }
              }
              
              cell.mainUsername = mainUsername
              cell.mainImageString = mainImageString
              cell.mainUID = mainUID
              
              cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
              
              authService.shared.downloadImage(from: imageString[indexPath.row]) { image, error in
                  if officeImages.pics.keys.contains(self.imageString[indexPath.row]){
                      cell.profileImage.image = officeImages.pics[self.imageString[indexPath.row]]
                  }else{
                      cell.profileImage.image = image
                  }
                  
              }
              return cell
          case .section2:
              // Configure cells for section 2
              let cell = tableView.dequeueReusableCell(withIdentifier: "secondNotificationsCell", for: indexPath) as! secondNotificationsCell
              
              cell.username.text = secondUsername[indexPath.row]
              cell.uid = secondUIDS[indexPath.row]
              cell.imageString = secondImageString[indexPath.row]
              cell.currentIndex = indexPath.row

              cell.acceptButtonAction = { [weak self] currentIndex,didAccept,gameID in
                  // Use the currentIndex in your logic
                  print("The bool is: \(didAccept)")
                  print("Accept button tapped for index: \(currentIndex)")
                  self?.currentIndex = currentIndex
                  // Reload the table view data if needed
                  self?.didAccept = didAccept
                  self?.player2GameID = gameID
                  print("THE GAME ID IN NOTI ACCEPT: \(self!.player2GameID)")
                  
                  DispatchQueue.main.async {
                      self?.tableView.reloadData()
                  }
                  self?.performSegue(withIdentifier: "notiToGameboard", sender: nil)
              }
              
              cell.ignoreButtonAction = { [weak self] currentIndex in
                  print("The ignore button was tapped")
                  self?.secondUsername.remove(at: currentIndex)
                  self?.secondImageString.remove(at: currentIndex)
                  self?.secondUIDS.remove(at: currentIndex)
                  DispatchQueue.main.async {
                      self?.tableView.reloadData()
                  }
              }
              
              cell.mainUsername = mainUsername
              cell.mainImageString = mainImageString
              cell.mainUID = mainUID
              
              cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
              
              authService.shared.downloadImage(from: secondImageString[indexPath.row]) { image, error in
                  if officeImages.pics.keys.contains(self.secondImageString[indexPath.row]){
                      cell.profileImage.image = officeImages.pics[self.secondImageString[indexPath.row]]
                  }else{
                      cell.profileImage.image = image
                  }
                  
              }
              
              return cell
          case .none:
              return UITableViewCell()
          }
      }
      
      func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          return TableSection(rawValue: section)?.title
      }
}

// Define your sections
enum TableSection: Int, CaseIterable {
    case section1
    case section2
    
    var title: String {
        switch self {
        case .section1: return "Friend Requests"
        case .section2: return "Game Requests"
        }
    }
}
