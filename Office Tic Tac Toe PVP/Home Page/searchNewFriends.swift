//
//  searchNewFriends.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit
import FirebaseAuth

class searchNewFriends: UIViewController {
    
    var userNameArray: [String] = []
    var profileImageArray: [String] = []
    var uids: [String] = []
    
    var otherUID: String?
    
    
    var usersData: [nameAndUID] = []
    
    var friendsUID: [String] = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Call the function
         authService.shared.getAllUsers { usersWithUIDs, error in
             if let error = error {
                 print("Error retrieving users: \(error.localizedDescription)")
                 return
             }
             if let usersWithUIDs = usersWithUIDs{
                 print("The users uids are: \(usersWithUIDs)")
                 
                 // Filter out users who are already friends
                 // nonFriends will contain only those users who are not the current user and are not already friends, based on the conditions specified in the closure. It filters out users who should not be displayed as they are either the current user or are already friends.
                let nonFriends = usersWithUIDs.filter { user, uid in
                    return uid != Auth.auth().currentUser?.uid && !self.friendsUID.contains(uid)
                }
                 
                 //success
                 for (user, uid) in nonFriends{
                     self.userNameArray.append(user.username)
                     self.profileImageArray.append(user.profileImage)
                     self.uids.append(uid)
                 }
             }
             DispatchQueue.main.async {
                 self.tableView.reloadData()
             }
         }
        
        authService.shared.getFriends { friends, error in
            if let error = error {
                print("Error getting friends: \(error.localizedDescription)")
                return
            }
            
            if let friends = friends {
                for data in friends{
                    self.friendsUID.append(data.uid!)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
}

extension searchNewFriends: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "searchNewfFriendsCell", for: indexPath) as! searchNewfFriendsCell
    
        authService.shared.downloadImage(from: profileImageArray[indexPath.row]) { image, error in
             if officeImages.pics.keys.contains(self.profileImageArray[indexPath.row]){
                 cell.profileImage.image = officeImages.pics[self.profileImageArray[indexPath.row]]
             }else{
                 cell.profileImage.image = image
             }
                         
             cell.imageString = self.profileImageArray[indexPath.row]
             cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
             cell.username.text = self.userNameArray[indexPath.row]
             cell.uid = self.uids[indexPath.row]
         }

        return cell
    }
}
