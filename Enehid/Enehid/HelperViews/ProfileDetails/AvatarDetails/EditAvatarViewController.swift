//
//  AvatarViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/31/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class EditAvatarViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var outfitImageView: UIImageView!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBOutlet weak var skinOverlayView: UIImageView!
    @IBOutlet weak var avatarBaseImageView: UIImageView!
    @IBOutlet weak var avatarContainerView: UIView!
    
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var featureSegmentedControl: UISegmentedControl!
    
    enum AvatarFeature: Int, CaseIterable {
        case skin = 0, eyes, mouth, accessories
    }
    
    var selectedSkin: String = "skin_tone_01"
    var selectedEyes: String = "eyes_style_01"
    var selectedMouth: String = "mouth_type_01"
    var selectedAccessory: String = "accessory_01"
    
    let avatarOptions: [AvatarFeature: [String]] = [
        .skin: ["skin_tone_01", "skin_tone_02", "skin_tone_03", "skin_tone_04", "skin_tone_05", "skin_tone_06", "skin_tone_07", "skin_tone_08", "skin_tone_09", "skin_tone_10", "skin_tone_11", "skin_tone_12", "skin_tone_13", "skin_tone_14", "skin_tone_15", "skin_tone_16", "skin_tone_17", "skin_tone_18", "skin_tone_19", "skin_tone_20", "skin_tone_21"],
        .eyes: ["eyes_style_01", "eyes_style_02", "eyes_style_03", "eyes_style_04", "eyes_style_05"],
        .mouth: ["mouth_type_01", "mouth_type_02", "mouth_type_03", "mouth_type_04", "mouth_type_05", "mouth_type_06", "mouth_type_07", "mouth_type_08", "mouth_type_09"],
        .accessories: ["accessory_01", "accessory_02", "accessory_03", "accessory_04", "accessory_05", "accessory_06", "accessory_07", "accessory_08", "accessory_09", "accessory_10", "accessory_11", "accessory_12", "accessory_13", "accessory_14"]
    ]

    
    var selectedFeature: AvatarFeature = .skin

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        
        
        avatarBaseImageView.image = UIImage(named: "pin_base")
        
        optionsCollectionView.reloadData()
    }
    
    
    @IBAction func featureChanged(_ sender: UISegmentedControl) {
        if let newFeature = AvatarFeature(rawValue: sender.selectedSegmentIndex) {
            selectedFeature = newFeature
            optionsCollectionView.reloadData()
        }
    }
    
    
    @IBAction func onTapSave(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

            guard let finalImage = renderFinalAvatarImage() else { return }

            uploadAvatarImage(finalImage) { profilePictureURL in
                let db = Firestore.firestore()

                var data: [String: Any] = [
                    "avatarSkin": self.selectedSkin,
                    "avatarEyes": self.selectedEyes,
                    "avatarMouth": self.selectedMouth,
                    "avatarAccessory": self.selectedAccessory
                ]

                if let url = profilePictureURL {
                    data["profilePictureURL"] = url
                }

                db.collection("users").document(userID).setData(data, merge: true) { error in
                    if let error = error {
                        print("Failed to save avatar data: \(error)")
                    } else {
                        print("Avatar data + image saved")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }
    
    func renderFinalAvatarImage() -> UIImage? {
        let size = avatarContainerView.bounds.size

        // Begin graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        // Draw layers in order
        avatarBaseImageView.image?.draw(in: CGRect(origin: .zero, size: size))
        skinOverlayView.image?.draw(in: CGRect(origin: .zero, size: size))
        eyesImageView.image?.draw(in: CGRect(origin: .zero, size: size))
        outfitImageView.image?.draw(in: CGRect(origin: .zero, size: size))
        accessoryImageView.image?.draw(in: CGRect(origin: .zero, size: size))

        // Get the new image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }
    
    func uploadAvatarImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.pngData(),
              let userID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("avatars/\(userID).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Upload error: \(error)")
                completion(nil)
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(nil)
                    return
                }

                completion(url.absoluteString)
            }
        }
    }


    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    


}

extension EditAvatarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarOptions[selectedFeature]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath)
        
        let imageName = avatarOptions[selectedFeature]?[indexPath.item] ?? ""
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFit // <== ensure this is set in code too
            imageView.clipsToBounds = true
        }
        
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5

        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = avatarOptions[selectedFeature]?[indexPath.item] ?? ""
        
        switch selectedFeature {
        case .skin:
            skinOverlayView.image = UIImage(named: selectedImage)
            selectedSkin = selectedImage
        case .eyes:
            eyesImageView.image = UIImage(named: selectedImage)
            selectedEyes = selectedImage
        case .mouth:
            outfitImageView.image = UIImage(named: selectedImage)
            selectedMouth = selectedImage
        case .accessories:
            accessoryImageView.image = UIImage(named: selectedImage)
            selectedAccessory = selectedImage
        }

//
//        switch selectedFeature {
//        case .skin:
//            skinOverlayView.image = UIImage(named: selectedImage)
//        case .eyes:
//            eyesImageView.image = UIImage(named: selectedImage)
//        case .mouth:
//            outfitImageView.image = UIImage(named: selectedImage)
//        case .accessories:
//            accessoryImageView.image = UIImage(named: selectedImage)
//        }
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 80, height: 80)
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = 3 // or 4 for smaller items
        let padding: CGFloat = 10
        let totalSpacing = padding * (itemsPerRow + 1)

        let availableWidth = collectionView.bounds.width - totalSpacing
        let widthPerItem = floor(availableWidth / itemsPerRow)

        return CGSize(width: widthPerItem, height: widthPerItem * 1.3) // make taller if needed
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }


}
