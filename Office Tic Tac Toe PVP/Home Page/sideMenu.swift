//
//  sideMenu.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/12/24.
//

import UIKit

class sideMenu: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        showSignOutAlert()
    }
    
    
    func showSignOutAlert() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to signout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        }
        alert.addAction(cancelAction)
        alert.addAction(signOutAction)
        present(alert, animated: true, completion: nil)
    }
      
    func performSignOut() {
        authService.shared.signOut { [weak self] error in
            guard let self = self else { return }
            if let error = error {
//                AlertCenter.showLogoutError(on: self, with: error)
                print("There was an error: \(error)")
                return
            }
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
        }
      }
  }
    

