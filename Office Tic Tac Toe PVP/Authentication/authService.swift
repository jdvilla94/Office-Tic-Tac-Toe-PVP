//
//  authService.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/8/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class authService{
    
    public static let shared = authService()
    private init(){}//this is a singleton initlizes when app turns on, access any where
    
    enum SignInMethod {
        case emailAndPassword
        case google
    }
    
    /// A method to register the user
    /// - Parameters:
    ///   - userRequest: the users information(email, password, username)
    ///   - completion: a completion with two values...
    ///   - bool : wasregistered  - determins if the user was registered and saved in the database correctly
    ///   - error? an optional error if firebase provides one
    ///
    
    
    public func registerUser(with userRequest: registerUserRequest, completion: @escaping (Bool, Error?) -> Void){//completion handler calls a function, it runs if it passes completion, asycn way of doing things. we need to upload data, and it takes a few seconds. call completion when everything happens
        let username = userRequest.username
        let email = userRequest.email
        let profileImage = userRequest.profileImage
        let password = userRequest.password
        //        let uid = userRequest.uid
        
        Auth.auth().createUser(withEmail: email!, password: password!) { result, error in
            
            if let error = error {
                completion(false,error)
                return
            }
            
            guard let resultUser = result?.user else{
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users")
                .document(resultUser.uid)
                .setData([
                    "username":username,
                    "email": email,
                    "profileImage": profileImage
                    
                ]) { error in
                    if let error = error {
                        completion(false,error)
                        return
                    }
                    //                completion(true,nil)
                    //calling completion handlers twice thats why its getting two views
                    
                }
            
            
            
            // Add data to the "friends" collection
            db.collection("allUsers").document(resultUser.uid).setData([
                "Sent Requets":[],
                "Recieved Requests": [],
                "Friends": []
            ]) { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                // Both Firestore operations completed successfully
                completion(true, nil)
                
                //                completion(true,nil)
                //calling completion handlers twice thats why its getting two views
            }
        }
    }
    
    public func registerGoolgleUser(with userRequest: registerUserRequest, completion: @escaping (Bool, Error?) -> Void){//completion handler calls a function, it runs if it passes completion, asycn way of doing things. we need to upload data, and it takes a few seconds. call completion when everything happens
        let username = userRequest.username
        let email = userRequest.email
        let profileImage = userRequest.profileImage
        let password = userRequest.password
        let uid = userRequest.uid
        
        
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid!)
            .setData([
                "username":username,
                "email": email,
                "profileImage": profileImage
                
            ]) { error in
                if let error = error {
                    completion(false,error)
                    return
                }
            }
        
        
        
        // Add data to the "friends" collection
        db.collection("allUsers").document(uid!).setData([
            "Sent Requets":[],
            "Recieved Requests": [],
            "Friends": []
        ]) { error in
            if let error = error {
                completion(false, error)
                return
            }
            // Both Firestore operations completed successfully
            completion(true, nil)
            
            //                completion(true,nil)
            //calling completion handlers twice thats why its getting two views
        }
    }
    
    
    
    public func signIn(with userRequet: loginUserRequest,completion: @escaping (Error?) -> Void){
        Auth.auth().signIn(withEmail: userRequet.email, password: userRequet.password) { result, error in
            if let error = error {
                completion(error)
                return
            } else{
                completion(nil)
            }
        }
    }
    
    
    public func signOut(completion: @escaping (Error?) -> Void){
        do{
            try Auth.auth().signOut()
            completion(nil)
        }catch let error {
            completion(error)
        }
    }
    
    
    
    public func getUser(completion: @escaping (User?, Error?) -> Void){
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userUID)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil,error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let username = snapshotData["username"] as? String,/*returns key value pair*/
                   let email = snapshotData["email"] as? String,
                   let profileImage = snapshotData["profileImage"] as? String{
                    let user = User(email: email, username: username, profileImage: profileImage)
                    
                    completion(user,nil)
                }
            }
    }
    
    public func getOtherUser(_ player:String, completion: @escaping (User?, Error?) -> Void){
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(player)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil,error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let username = snapshotData["username"] as? String,/*returns key value pair*/
                   let email = snapshotData["email"] as? String,
                   let profileImage = snapshotData["profileImage"] as? String{
                    let user = User(email: email, username: username, profileImage: profileImage)
                    
                    completion(user,nil)
                }
            }
    }
    
    public func getAllUsers(completion: @escaping ([(User, String)]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var usersWithUIDs: [(User, String)] = []
            
            for document in snapshot!.documents {
                if let userData = document.data() as? [String: Any],
                   let username = userData["username"] as? String,
                   let email = userData["email"] as? String,
                   let profileImage = userData["profileImage"] as? String {
                    let user = User(email: email, username: username, profileImage: profileImage)
                    let uid = document.documentID
                    let userWithUID = (user, uid)
                    usersWithUIDs.append(userWithUID)
                }
            }
            
            completion(usersWithUIDs, nil)
        }
    }
    
    public func addFriend(_ friends: friendInfo, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "name": friends.username!,
            "image": friends.profileImage!,
            "uid": userUID
        ]
        
        // Update the "received requests" array in Firestore
        db.collection("allUsers")
            .document(friends.uid!)
            .updateData([
                "Recieved Requests": FieldValue.arrayUnion([data])
            ]) { error in
                completion(error)
            }
        
    }
    
    public func sentRequest(_ friends: friendInfo, completion: @escaping (Error?) -> Void){
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        
        let db = Firestore.firestore()
        
        let data: [String:Any] = [
            "name": friends.username,
            "image": friends.profileImage,
            "uid":friends.uid
        ]
        
        //update the sent requests
        db.collection("allUsers")
            .document(userUID)
            .updateData([
                "Sent Requests": FieldValue.arrayUnion([data])
            ]) {error in
                completion(error)
            }
        
    }
    
    public func acceptFriendRequest(_ friends: friendInfo, _ user: newUser, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        // Retrieve the current "Recieved Requests" array
        db.collection("allUsers").document(userUID).getDocument { snapshot, error in
            guard let document = snapshot, document.exists else {
                completion(error)
                return
            }
            
            if var receivedRequests = document.data()?["Recieved Requests"] as? [[String: Any]] {
                // Remove the friend request with matching UID
                receivedRequests.removeAll { $0["uid"] as? String == friends.uid }
                
                // Update the "Recieved Requests" array in Firestore
                db.collection("allUsers")
                    .document(userUID)
                    .updateData(["Recieved Requests": receivedRequests]) { error in
                        completion(error)
                    }
                
                // Add the friend to the "Friends" array
                let data: [String: Any] = [
                    "name": friends.username!,
                    "image": friends.profileImage!,
                    "uid": friends.uid!
                ]
                
                db.collection("allUsers")
                    .document(userUID)
                    .updateData(["Friends": FieldValue.arrayUnion([data])]) { error in
                        completion(error)
                    }
                
                //add frined to your own friends database in firestore
                let userData: [String:Any] = [
                    "name":user.name!,
                    "image":user.image!,
                    "uid":user.uid!
                ]
                
                db.collection("allUsers")
                    .document(friends.uid!)
                    .updateData(["Friends": FieldValue.arrayUnion([userData])]) { error in
                        completion(error)
                    }
                
            } else {
                completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error parsing Received Requests array"]))
            }
        }
    }
    
    public func removeRequestsFromFirebase(index: Int) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        let userDocRef = Firestore.firestore().collection("allUsers").document(userUID)
        
        // Fetch the existing favorites array from Firestore
        userDocRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            //this is the array to get the
            var requestsReceived = document["Recieved Requests"] as? [[String: Any]] ?? []
            
            // Check if the index is valid
            guard index < requestsReceived.count else {
                print("Invalid index")
                return
            }
            
            // Remove the element at the specified index
            requestsReceived.remove(at: index)//this removes all field and data at this index
            
            // Update the favorites array in Firebase
            userDocRef.updateData([
                "Recieved Requests": requestsReceived//replacing the new array and all fields
            ]) { error in
                if let error = error {
                    print("Error removing element from Firebase: \(error.localizedDescription)")
                } else {
                    print("Element removed successfully from Firebase")
                }
            }
        }
        
        
    }
    
    
    public func getReceivedRequests(completion: @escaping ([friendInfo]?, Error?) -> Void) {
        
        var userUID = Auth.auth().currentUser?.uid
        
        
        let db = Firestore.firestore()
        
        db.collection("allUsers")
            .document(userUID!)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let receivedRequestsData = snapshotData["Recieved Requests"] as? [[String: Any]] {
                    
                    var receivedRequests: [friendInfo] = []
                    
                    for requestData in receivedRequestsData {
                        print("reuest data")
                        if let image = requestData["image"] as? String,
                           let name = requestData["name"] as? String,
                           let uid = requestData["uid"] as? String {
                            
                            let receivedRequest = friendInfo(username: name, profileImage: image, uid: uid)
                            receivedRequests.append(receivedRequest)
                        }
                    }
                    
                    completion(receivedRequests, nil)
                } else {
                    completion(nil, nil)
                }
            }
    }
    
    
    
    public func getFriends(completion: @escaping ([friendInfo]?, Error?) -> Void) {
        
        var userUID = Auth.auth().currentUser?.uid
        
        
        let db = Firestore.firestore()
        
        db.collection("allUsers")
            .document(userUID!)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let receivedRequestsData = snapshotData["Friends"] as? [[String: Any]] {
                    
                    var receivedRequests: [friendInfo] = []
                    
                    for requestData in receivedRequestsData {
                        print("reuest data")
                        if let image = requestData["image"] as? String,
                           let name = requestData["name"] as? String,
                           let uid = requestData["uid"] as? String {
                            
                            let receivedRequest = friendInfo(username: name, profileImage: image, uid: uid)
                            receivedRequests.append(receivedRequest)
                        }
                    }
                    
                    completion(receivedRequests, nil)
                } else {
                    completion(nil, nil)
                }
            }
    }
    
    
    public func downloadImage(from urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                } else {
                    let error = NSError(domain: "YourApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create UIImage from data."])
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }.resume()
        } else {
            let error = NSError(domain: "YourApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
    
    public func sendGameInvite(_ friends: friendInfo, _ user: newUser, completion: @escaping (Error?) -> Void){
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        
        let db = Firestore.firestore()
        
        let data: [String:Any] = [
            "name": friends.username,
            "image": friends.profileImage,
            "uid":friends.uid
        ]
        
        //update the sent requests
        db.collection("allUsers")
            .document(userUID)
            .updateData([
                "Game Invites Sent": FieldValue.arrayUnion([data])
            ]) {error in
                completion(error)
            }
        
        
        let newData:  [String:Any] = [
            "name":user.name,
            "image": user.image,
            "uid":user.uid
        ]
        
        //put sent request in recieved game requets
        db.collection("allUsers")
            .document(friends.uid!)
            .updateData([
                "Game Invites Recieved": FieldValue.arrayUnion([newData])
            ]) { error in
                completion(error)
            }
    }
    
    public func getGameInvites(completion: @escaping ([friendInfo]?, Error?) -> Void) {
        
        var userUID = Auth.auth().currentUser?.uid
        
        
        let db = Firestore.firestore()
        
        db.collection("allUsers")
            .document(userUID!)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let receivedRequestsData = snapshotData["Game Invites Recieved"] as? [[String: Any]] {
                    
                    var receivedRequests: [friendInfo] = []
                    
                    for requestData in receivedRequestsData {
                        print("reuest data")
                        if let image = requestData["image"] as? String,
                           let name = requestData["name"] as? String,
                           let uid = requestData["uid"] as? String {
                            
                            let receivedRequest = friendInfo(username: name, profileImage: image, uid: uid)
                            receivedRequests.append(receivedRequest)
                        }
                    }
                    
                    completion(receivedRequests, nil)
                } else {
                    completion(nil, nil)
                }
            }
    }
    
    public func updateGameInviteAcceptedStatus(userUID: String, friendUID: String, didAccept: Bool, completion: @escaping (Error?) -> Void) {
         let db = Firestore.firestore()
         
         // Generate a random game ID
         let gameID = UUID().uuidString
         
         // Assuming userUID is the UID of the current user
         let currentUserRef = db.collection("allUsers").document(userUID)
         
         // Assuming friendUID is the UID of the friend who sent the game invite
         let friendRef = db.collection("allUsers").document(friendUID)
         
         //add game id to new game server collection
 //        let gameServer = db.collection("gameIDs").document(gameID)
         
         // Create the data structure for the didAccept field
         let didAcceptData: [String: Any] = [
             "didAccept": didAccept,
         ]
         
         // Update the current user's document to add the didAccept data to the first element of the array
         currentUserRef.updateData([
             "Game Invites Recieved.0.didAccept": didAccept,
             "Game Invites Recieved.0.gameID": gameID
         ]) { error in
             if let error = error {
                 completion(error)
                 return
             }
             
             // Update the friend's document to add the didAccept data to the first element of the array
             friendRef.updateData([
                 "Game Invites Sent.0.didAccept": didAccept,
                 "Game Invites Sent.0.gameID": gameID,
             ]) { error in
                 completion(error)
             }
         }
         
         
         // Set data for the game server document
         let gameServerData: [String: Any] = [
             "player1": userUID,
             "player2": friendUID
         ]
         
         db.collection("gameIDs").document(gameID).setData([
             "player1": userUID,
             "player2": friendUID
         ]) { error in
             if let error = error {
                 print("Error adding gameID document: \(error.localizedDescription)")
                 completion(error)
                 return
             }
             
             
             
         }
         
         
     }

    
    public func getDidAccept(completion: @escaping ([gameIDInfo]?, Error?) -> Void) {
        
        var userUID = Auth.auth().currentUser?.uid
        
        
        let db = Firestore.firestore()
        
        db.collection("allUsers")
            .document(userUID!)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot,
                   let snapshotData = snapshot.data(),
                   let receivedRequestsData = snapshotData["Game Invites Sent"] as? [[String: Any]] {
                    
                    var receivedRequests: [gameIDInfo] = []
                    
                    for requestData in receivedRequestsData {
                        print("data for game id is....")
                        if let didAccept = requestData["didAccept"] as? Bool,
                           let gameID = requestData["gameID"] as? String{
                            let receivedRequest = gameIDInfo(didAccept: didAccept, gameID: gameID)
                            receivedRequests.append(receivedRequest)
                        }
                    }
                    
                    completion(receivedRequests, nil)
                } else {
                    completion(nil, nil)
                }
            }
    }
    
    public func getPlayersForGameID(_ gameID: String, completion: @escaping (String?, String?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("gameIDs")
            .document(gameID)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, nil, error)
                    return
                }

                if let snapshot = snapshot,
                   let snapshotData = snapshot.data() {
                    // Print snapshot data for debugging
                    print("Snapshot Data for GameID \(gameID): \(snapshotData)")
                    
                    // Access player1 and player2 fields
                    if let player1UID = snapshotData["player1"] as? String,
                       let player2UID = snapshotData["player2"] as? String {
                        completion(player1UID, player2UID, nil)
                    } else {
                        // Handle the case where player1 or player2 fields are missing
                        completion(nil, nil, NSError(domain: "Firestore", code: 1, userInfo: ["description": "Player UID not found"]))
                    }
                } else {
                    completion(nil, nil, error)
                }
            }
    }
    
    public func updatePlayerMoves(_ gameID: String, playerMoves: [Int],completion: @escaping (Error?,[Int]?) -> Void) {
        var userUID = Auth.auth().currentUser?.uid
        
        let db = Firestore.firestore()
        db.collection("gameIDs")
            .document(gameID)
            .getDocument { snapshot,error in
                if let error = error{
                    completion(error,nil)
                    return
                }
                
                if let snapshotData = snapshot?.data() {
                       // Access player1 and player2 fields
                       if let player1UID = snapshotData["player1"] as? String,
                          let player2UID = snapshotData["player2"] as? String {
                           if userUID == player1UID || userUID == player2UID {
                               var updateData: [String:Any] = ["allMoves":playerMoves,"player1Turn":false,"player2Turn":true]
                               // Update the document with the player's moves
                               db.collection("gameIDs")
                                   .document(gameID)
                                   .updateData(updateData) { error in
                                       completion(error,playerMoves)
                                   }
                           } else {
                               // Handle the case where the current user is neither player1 nor player2
                               completion(NSError(domain: "Authentication", code: 2, userInfo: ["description": "Current user is not a player in the game"]),nil)
                           }
                       } else {
                           // Handle the case where player1 or player2 fields are missing
                           completion(NSError(domain: "Firestore", code: 1, userInfo: ["description": "Player UID not found"]),nil)
                       }
                   } else {
                       completion(error,nil)
                   }
                

                }
                
        }
    
    func getCurrentPlayer(forGameID gameID: String, completion: @escaping (String?,Bool?, Bool?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("gameIDs")
            .document(gameID)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, nil, nil, error)
                    return
                }

                if let snapshotData = snapshot?.data(), let currentPlayer = snapshotData["currentPlayer"] as? String,
                   let player1 = snapshotData["player1Turn"] as? Bool, let player2 = snapshotData["player2Turn"] as? Bool
                {
                    print("the current player is database is: \(currentPlayer)")
                    completion(currentPlayer, player1, player2, nil)
                } else {
                    // Handle the case where currentPlayer field is missing or not a String
                    completion(nil, nil, nil, NSError(domain: "Firestore", code: 1, userInfo: ["description": "Current player not found"]))                }
            }
    }
    
    func updateCurrentPlayer(forGameID gameID: String, currentPlayer: String,player1Turn: Bool, player2Turn:Bool, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("gameIDs")
            .document(gameID)
            .updateData(["currentPlayer": currentPlayer,
                         "player1Turn":player1Turn,
                         "player2Turn":player2Turn
                        ]) { error in
                completion(error)
            }
    }

    
    public func pickTwoRandomImages() -> (UIImage, UIImage) {
        // Extract all images from the officeImages struct
        let allImages = Array(officeImages.pics.values)

        // Make sure there are at least two images in the array
        guard allImages.count >= 2 else {
            fatalError("There should be at least two images in the array.")
        }

        // Shuffle the array to randomize the order
        let shuffledImages = allImages.shuffled()

        // Pick the first two images from the shuffled array
        let firstImage = shuffledImages[0]
        let secondImage = shuffledImages[1]

        return (firstImage, secondImage)
    }
    }
    
    


    





