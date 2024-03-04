//
//  theOfficeImages.swift
//  Office Tic Tac Toe PVP
//
//  Created by JD Villanueva on 2/13/24.
//

import UIKit

class theOfficeImages: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var currentImage:UIImage?
    var currentName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.roundCorners(corners: [.topLeft,.topRight], radius: 15)
        // Create a new layer for the border
          let borderLayer = CALayer()
          borderLayer.frame = self.view.bounds
          borderLayer.cornerRadius = 15
          borderLayer.borderWidth = 1
          borderLayer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor

          // Add the border layer to the view's layer
          self.view.layer.addSublayer(borderLayer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! createAccount
        DispatchQueue.main.async {
            destVC.profileImage.image = self.currentImage
            destVC.profileImageString = self.currentName
        }
    }
}

extension theOfficeImages: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return officeImages.pics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "theOfficeCell", for: indexPath) as! theOfficeCell
        
        let keys = Array(officeImages.pics.keys)
        let currentKey = keys[indexPath.item]

          if let currentImage = officeImages.pics[currentKey] {
              cell.officeImage.image = currentImage
              cell.officeName.text = currentKey
          }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keys = Array(officeImages.pics.keys)
        let currentKey = keys[indexPath.item]
        
        if let image = officeImages.pics[currentKey] {
            // Save the selected image to the variable
            currentImage = image
        }
        currentName = currentKey
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

