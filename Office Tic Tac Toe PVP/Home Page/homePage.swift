//
//  homePage.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/12/24.
//

import UIKit
import FirebaseAuth

class homePage: UIViewController {
    
    var containerVisible = false
    @IBOutlet var containerLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var sideMenuView: UIView!
    
    var profileImage:UIImage?
    var profileName:String?
    
    var player2ImageString: String?
    var player2UID:String?
    var player2Username:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        authService.shared.getUser { [weak self] user, error in
            if let error = error {
                print("There was an error in getting favFoodandCity\(error)")
                return
            }
            
            if let user = user {
                
                authService.shared.downloadImage(from: user.profileImage, completion: { image, error in
                    if officeImages.pics.keys.contains(user.profileImage){
                        print("THe image string is: \(user.profileImage)")
                        DispatchQueue.main.async {
                            self?.profileImage = officeImages.pics[user.profileImage]
                            self?.setupNavigationBar(with: self!.profileImage!)
                            self?.player2Username = user.username
                            self?.player2ImageString = user.profileImage
                            self?.player2UID = Auth.auth().currentUser?.uid
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self?.setupNavigationBar(with: image!)
                            self?.profileImage = image
                        }
                       
                    }
        
                })
                self?.profileName = user.username
            }
        }
        
        addSlideGestureToContainer()
    }
    
    func setupNavigationBar(with image: UIImage) {
        // Create a circular profile image with a specific size
        let imageSize = CGSize(width: 40, height: 40)
        let circularImage = image.circularImage(size: imageSize)

        // Create a UIButton to hold the circular image
        let imageButton = UIButton(type: .custom)
        imageButton.setImage(circularImage, for: .normal)
        imageButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)

        // Create a UIBarButtonItem with the custom UIButton
        let barButtonItem = UIBarButtonItem(customView: imageButton)

        // Set the custom UIBarButtonItem as the leftBarButtonItem of the navigationItem
        navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func profileImageTapped() {
        // Handle the profile image tap action if needed
//        print("Profile image tapped!")
        if(containerVisible){
              UIView.animate(withDuration: 0.5,animations:  {
                  //hide the menu to the left
                  self.containerLeadingConstraint.constant = 0 - self.sideMenuView.frame.size.width
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
                  self.containerLeadingConstraint.constant = 0
                  self.view.layoutIfNeeded()
              }, completion: { _ in
                  // Reset the container visibility flag
                  self.containerVisible = true
              })
          }
          print("The popupslider was tapped")
          containerVisible = !containerVisible
      }
    
    func addSlideGestureToContainer(){
        let leftSlideGesture = UISwipeGestureRecognizer(target: self, action: #selector(addSlideGesture))
        leftSlideGesture.direction = .left
        
        let rightSlideGesture = UISwipeGestureRecognizer(target: self, action: #selector(addSlideGesture))
        rightSlideGesture.direction = .right
//        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(leftSlideGesture)
        self.view.addGestureRecognizer(rightSlideGesture)
    }
    
    @objc func addSlideGesture(){
        if(containerVisible){
              UIView.animate(withDuration: 0.5,animations:  {
                  //hide the menu to the left
                  self.containerLeadingConstraint.constant = 0 - self.sideMenuView.frame.size.width
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
                  self.containerLeadingConstraint.constant = 0
                  self.view.layoutIfNeeded()
              }, completion: { _ in
                  // Reset the container visibility flag
                  self.containerVisible = true
              })
          }
          print("The popupslider was tapped")
          containerVisible = !containerVisible
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        performSegue(withIdentifier: "homepageToNewgame", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homepageToNewgame"{
            let destVC = segue.destination as? newGame
            destVC?.player2Username = player2Username
            destVC?.player2ImageString = player2ImageString
            destVC?.player2UID = player2UID
        }
    }
    

    }

extension UIImage {
    func circularImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let circularImage = renderer.image { context in
            let bounds = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: bounds, cornerRadius: size.width / 2).addClip()
            draw(in: bounds)
        }
        return circularImage
    }
}
