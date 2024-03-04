//
//  loginWithGoogle.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/8/24.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import GoogleSignInSwift

class loginWithGoogle: UIViewController{

    
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    
    @IBOutlet var continueWithGoogleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("The current user auth is: \(Auth.auth().currentUser)")
    }
    
    func updateUI(){
        continueWithGoogleButton.layer.borderWidth = 1
        continueWithGoogleButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        continueWithGoogleButton.layer.cornerRadius = 15
    }
    
    @IBAction func googleSignIn(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { authentication, error in
            
            if let error = error {
                print("There was an error signing the user in -> \(error)")
                return
            }
            guard let user = authentication?.user,
                  let idToken = user.idToken?.tokenString else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            let dimension: UInt = 200
            let profileImageURL = user.profile?.imageURL(withDimension: dimension)?.absoluteString
            
            let registerUserRequest = registerUserRequest(uid:"", username: user.profile?.name ?? "no name",
                                                          email: user.profile?.email ?? "no email",
                                                          profileImage: profileImageURL)
            
            //            print("THE REGISTERED USER IS -> \(registerUserRequest)")
            print("YOUR GOOGLE EMAIL IS: \(user.profile?.email ?? "no email")")
            print("YOUR GOOGLE NAME IS: \(user.profile?.name ?? "no name")")
//            print("THE GOOGLE Image IS \(user.profile?.hasImage)")
            
            let db = Firestore.firestore()
            let usersCollection = db.collection("users") // Replace with the name of your collection
            
            // Authenticate with Firebase using Google credential
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Firebase Sign-In Error: \(error.localizedDescription)")
                    return
                }
                
                // User signed in successfully, get the UID
                if let uid = authResult?.user.uid {
                    print("Firebase UID: \(uid)")
                    
                    // Update registerUserRequest with Firebase UID
                    var updatedRegisterUserRequest = registerUserRequest
                    updatedRegisterUserRequest.uid = uid
                    
                    // Check if the email exists in Firestore
                    let db = Firestore.firestore()
                    let usersCollection = db.collection("users")
                    
                    usersCollection.whereField("email", isEqualTo: user.profile?.email).getDocuments { (querySnapshot, error) in
                        
                        
                        if let error = error {
                            print("Error fetching documents: \(error)")
                            return
                        } else if querySnapshot?.documents.isEmpty == false {
                            print("called here how many times")
                            // Email exists in Firestore, handle accordingly
                            print("Email exists in Firestore")
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "loginToHomepage", sender: nil)
                            }
                            // Your existing logic when email exists
                        } else {
                            // Email doesn't exist in Firestore, register the user
                            print("Email doesn't exist in Firestore")
                            authService.shared.registerGoolgleUser(with: updatedRegisterUserRequest) { [weak self] wasRegistered, error in
//                            authService.shared.registerUser(with: updatedRegisterUserRequest) { [weak self] wasRegistered, error in
                                guard let self = self else { return }
                                
                                if let error = error {
                                    print("Could not register user in Firestore: \(error)")
                                    return
                                }
                                
                                else if wasRegistered {
                                    print("Successfully added user to Firestore")
                                    // Your existing logic after user registration
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "loginToHomepage", sender: nil)
                                    }
                                    print("how many times are we seguing")
            
                                } else {
                                    print("Error registering user in Firestore")
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        let loginRequest = loginUserRequest(email: self.emailTF.text ?? "",
                                                    password: self.passwordTF.text ?? "")
                
        //check email
        if !validator.isValidEmail(for: loginRequest.email){
//                  AlertCenter.showInvalidEmailAlert(on: self)
            print("invalid email")
            return
        }
        
        //check password
        if !validator.isPasswordValid(for: loginRequest.password){
//                  AlertCenter.showInvalidPasswordAlert(on: self)
            print("invalid passsword")
            return
        }
        
        authService.shared.signIn(with: loginRequest) { [weak self] error in
            guard let self = self else {return}//stops retain cycles
            if let error = error {
//                      AlertCenter.showSignInErrorAlert(on: self, with: error)
                print("error signing into firestore")
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate{
                sceneDelegate.checkAuthentication()
            }else{
                print("we have an error with auth")
            }
        }
                
            }
    }
    
    


