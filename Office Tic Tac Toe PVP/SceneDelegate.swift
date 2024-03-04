//
//  SceneDelegate.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/8/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imp®ly the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        self.checkAuthentication()
    }

    public func checkAuthentication(){
        print(Auth.auth().currentUser?.uid)
            
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let db = Firestore.firestore()
            let usersCollection = db.collection("users") // Replace with the name of your collectio
            usersCollection.document(user?.uid ?? "no uid").getDocument { (document, error) in
                if let error = error {
                    // An error occurred while fetching the document, handle it here
                    print("An error occurred while fetching the document, handle it here")
                    return
                } else if document?.exists == true {
                    // The document with the given UID exists
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "homePage")
                    let homeNav = UINavigationController(rootViewController: vc)
                    //            homeNav.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = homeNav
                    print("uid exists, go to homepage")
                    return
                } else {
                    // The document with the given UID doesn't exist
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "loginWithGoogle")
                    let mainNav = UINavigationController(rootViewController: vc)
                    mainNav.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = mainNav
                    print("The document with the given UID doesn't exist")
                    return
                }
                
            }
        }
        }




}

