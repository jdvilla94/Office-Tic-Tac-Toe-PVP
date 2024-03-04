//
//  createAccount.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit
import FirebaseAuth

class createAccount: UIViewController,UITextFieldDelegate{
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var usernameTF: UITextField!
    
    var profileImageString:String?
    
    @IBOutlet var theOfficeContainerView: UIView!
    var containerVisible = false
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addGesture()
        
        // Set the delegate for text fields
        emailTF.delegate = self
        passwordTF.delegate = self
        usernameTF.delegate = self
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let registerUserRequest = registerUserRequest(username: self.usernameTF.text ?? "",
                                                              email: self.emailTF.text ?? "",
                                                              profileImage: profileImageString,
                                                            password: passwordTF.text
                                                            )
                
        //check username
        if !validator.isValidUsername(for: registerUserRequest.username!){
//                  AlertCenter.showInvalidUsernameAlert(on: self)
            print("invalid user")
            return
        }
        
        //check email
        if !validator.isValidEmail(for: registerUserRequest.email!){
//                  AlertCenter.showInvalidEmailAlert(on: self)
            print("invalid email")
            return
        }
        
        //check password
        if !validator.isPasswordValid(for: registerUserRequest.password!){
//                  AlertCenter.showInvalidPasswordAlert(on: self)
            print("invalid passsword")
            return
        }
        
        DispatchQueue.main.async {
            // User is already authenticated, proceed with registration and image upload
            authService.shared.registerUser(with: registerUserRequest) { [weak self] wasRegistered, error in
                guard let self = self else {return}//stops retain cycles
                    
                if let error = error {
//                    AlertCenter.showRegistrationErrorAlert(on: self, with: error)
                    print("couldnt log you into firestore")
                    print("\(error.localizedDescription)")
                    return
                }
                if wasRegistered {
                    // User successfully registered, handle authentication
                    Auth.auth().signIn(withEmail: registerUserRequest.email!, password: registerUserRequest.password!) { _, signInError in
                        if let signInError = signInError {
                            // Handle sign-in error
                            print("Error signing in after registration: \(signInError.localizedDescription)")
                        } else {
                            // User is authenticated, proceed with image upload
//                            self.uploadProfileImage()
                            print("user was succesfully authenticated")
                        }
                    }
                } else {
                    // Handle registration error
                    print("Error registering user: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

        
        
    }
    
    // Implement UITextFieldDelegate method to resign the keyboard when hitting return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
       }
    
    func addGesture(){
        // Add a tap gesture recognizer to your profile image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addSlideGesture))
        let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(addSlideGesture))
        slideDown.direction = .down
        profileImage.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(slideDown)
        profileImage.isUserInteractionEnabled = true
        
        // Add a tap gesture recognizer to dismiss the keyboard
//        let tappBack = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tappBack)
    }
    
    // Implement method to dismiss the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @objc func addSlideGesture(){
        if(containerVisible){
              UIView.animate(withDuration: 0.5,animations:  {
                  //hide the menu to the left
                  self.bottomConstraint.constant = 700
                  //move the view to original position
  //                self.bottomConstraint.constant = 0
                  self.view.layoutIfNeeded()
              }, completion: { _ in
                  // Reset the container visibility flag
                  self.containerVisible = false
              })
          }else{
              self.view.layoutIfNeeded()
              UIView.animate(withDuration: 0.5, animations: {
                  //move the menu to the right(show it)
                  self.bottomConstraint.constant = 0
                  self.view.layoutIfNeeded()
              }, completion: { _ in
                  // Reset the container visibility flag
                  self.containerVisible = true
              })
          }
          print("The popupslider was tapped")
          containerVisible = !containerVisible
    }
    
    @IBAction func unwindToCreateAccount(_ sender: UIStoryboardSegue){
        addSlideGesture()
    }
    
}

    


