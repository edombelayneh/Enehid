//
//  NewMemoryViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/1/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class NewMemoryViewController: UIViewController, UICollectionViewDelegate {
    
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var planPickerButton: UIButton!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    
    // MARK: - Properties
    var selectedImages: [UIImage] = []
    var selectedPlanId: String?
    var taggedUserIds: [String] = []
    private var uploadedImageURLs: [String] = []
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    
    @IBAction func onTappedUpload(_ sender: UIButton) {
        guard let planId = selectedPlanId else {
            showAlert(title: "Missing Plan", message: "Please select a plan.")
            return
        }
        
        guard !selectedImages.isEmpty else {
            showAlert(title: "No Media", message: "Please select at least one photo.")
            return
        }
        
        uploadButton.isEnabled = false
        
        uploadImages(images: selectedImages) { [weak self] urls in
            guard let self = self else { return }
            self.uploadedImageURLs = urls
            self.saveMemory(planId: planId)
        }
    }
    
    @IBAction func onTappedPlanPicker(_ sender: UIButton) {
        showPlanSelector()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func saveMemory(planId: String) {
        let memoryId = UUID().uuidString
        let currentUserId = "test-user-id" // Replace with real UID
        
        let memoryData: [String: Any] = [
            "id": memoryId,
            "ownerId": currentUserId,
            "planId": planId,
            "caption": captionTextView.text ?? "",
            "createdAt": Timestamp(date: Date()),
            "memoryURLs": uploadedImageURLs,
            "taggedUIds": taggedUserIds,
            "recommends": 0,
            "bookmarks": 0,
            "commentsCount": 0,
            "visibility": visibilitySwitch.isOn ? "public" : "friends"
        ]
        
        db.collection("memories").document(memoryId).setData(memoryData) { [weak self] error in
            self?.uploadButton.isEnabled = true
            
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Success", message: "Memory uploaded!") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func setupCollectionView() {
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
//        photosCollectionView.register(UINib(nibName: "MediaPreviewCell", bundle: nil), forCellWithReuseIdentifier: "MediaPreviewCell")
    }
    
    func showPlanSelector() {
        let alert = UIAlertController(title: "Select Plan", message: nil, preferredStyle: .actionSheet)
        
        // TODO: Replace with real plans from Firebase
        let plans = [("Weekend Trip", "plan123"), ("Birthday Bash", "plan456")]
        
        for (name, id) in plans {
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                self.planPickerButton.setTitle(name, for: .normal)
                self.selectedPlanId = id
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func uploadImages(images: [UIImage], completion: @escaping ([String]) -> Void) {
        var urls: [String] = []
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }
            
            let fileName = UUID().uuidString
            let ref = storage.reference().child("memories/\(fileName).jpg")
            
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Upload failed: \(error)")
                    group.leave()
                    return
                }
                
                ref.downloadURL { url, _ in
                    if let url = url {
                        urls.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(urls)
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
}

extension NewMemoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaPreviewCell", for: indexPath) as! MediaPreviewCell
        cell.configure(with: selectedImages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 180)
    }
}

