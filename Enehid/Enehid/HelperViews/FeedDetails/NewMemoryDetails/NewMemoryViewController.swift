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
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

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
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        guard let currentUID = Auth.auth().currentUser?.uid else {
            showAlert(title: "User Not Logged In", message: "Please Log In To save Memory")
            return
        }

        let userDocRef = db.collection("users").document(currentUID)

        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists {
                let username = document.get("username") as? String ?? "Unknown"

                let memoryData: [String: Any] = [
                    "id": memoryId,
                    "ownerId": currentUID,
                    "username": username,
                    "caption": self.captionTextView.text ?? "",
                    "recommends": 0,
                    "memoryURLs": self.uploadedImageURLs,
                    "bookmarks": 0,
                    "taggedUIds": self.taggedUserIds,
                    "commentsCount": 0,
                    "createdAt": Timestamp(date: Date()),
                    "visibility": self.visibilitySwitch.isOn ? "public" : "friends",
                    "planId": planId
                ]

                self.db.collection("memories").document(memoryId).setData(memoryData) { error in
                    self.uploadButton.isEnabled = true

                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self.showAlert(title: "Success", message: "Memory uploaded!") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                self.showAlert(title: "Error", message: "Could not fetch username.")
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

        guard let currUserId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let userPlansRef = db.collection("users").document(currUserId).collection("plans")

        userPlansRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user plans: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.presentNoPlansAlert()
                return
            }

            var fetchedPlans: [(String, String)] = []
            let dispatchGroup = DispatchGroup()
            let now = Date()

            // Setup formatter to convert string date to Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            for doc in documents {
                let planId = doc.documentID
                let status = doc.get("status") as? String ?? "pending"
                let dateString = doc.get("date") as? String ?? ""

                if let planDate = formatter.date(from: dateString), status == "accepted", planDate < now {
                    dispatchGroup.enter()

                    self.db.collection("plans").document(planId).getDocument { planDoc, error in
                        if let planDoc = planDoc, planDoc.exists {
                            let planName = planDoc.get("activityName") as? String ?? "Unnamed Plan"
                            fetchedPlans.append((planName, planId))
                        } else {
                            print("Plan document \(planId) not found: \(error?.localizedDescription ?? "")")
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                if fetchedPlans.isEmpty {
                    self.presentNoPlansAlert()
                    return
                }

                for (name, id) in fetchedPlans {
                    alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                        self.planPickerButton.setTitle(name, for: .normal)
                        self.selectedPlanId = id
                    }))
                }

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

    private func presentNoPlansAlert() {
        let noPlansAlert = UIAlertController(
            title: "No Eligible Plans",
            message: "You don't have any completed plans with friends. Memories can only be posted after accepted plans that have already occurred.",
            preferredStyle: .alert
        )
        noPlansAlert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(noPlansAlert, animated: true)
    }

    
//    func showPlanSelector() {
//        let alert = UIAlertController(title: "Select Plan", message: nil, preferredStyle: .actionSheet)
//
//        guard let currUserId = Auth.auth().currentUser?.uid else {
//            print("User not logged in.")
//            return
//        }
//
//        let userPlansRef = db.collection("users").document(currUserId).collection("plans")
//
//        userPlansRef.getDocuments { [weak self] snapshot, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error fetching user plans: \(error.localizedDescription)")
//                return
//            }
//
//            guard let documents = snapshot?.documents, !documents.isEmpty else {
//                self.presentNoPlansAlert()
//                return
//            }
//
//            var fetchedPlans: [(String, String)] = []
//            let dispatchGroup = DispatchGroup()
//            let now = Date()
//
//            for doc in documents {
//                let planId = doc.documentID
//                let status = doc.get("status") as? String ?? "pending"
//                let timestamp = doc.get("date") as? Timestamp
//                let planDate = timestamp?.dateValue() ?? Date.distantFuture
//                
//                // Filter only accepted and past plans
//                if status == "accepted", planDate < now {
//                    dispatchGroup.enter()
//                    
//                    self.db.collection("plans").document(planId).getDocument { planDoc, error in
//                        if let planDoc = planDoc, planDoc.exists {
//                            let planName = planDoc.get("activityName") as? String ?? "Unnamed Plan"
//                            fetchedPlans.append((planName, planId))
//                        } else {
//                            print("Plan document \(planId) not found: \(error?.localizedDescription ?? "")")
//                        }
//                        dispatchGroup.leave()
//                    }
//                }
//            }
//
//            dispatchGroup.notify(queue: .main) {
//                if fetchedPlans.isEmpty {
//                    self.presentNoPlansAlert()
//                    return
//                }
//
//                for (name, id) in fetchedPlans {
//                    alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
//                        self.planPickerButton.setTitle(name, for: .normal)
//                        self.selectedPlanId = id
//                    }))
//                }
//
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                self.present(alert, animated: true)
//            }
//        }
//    }
//
//    private func presentNoPlansAlert() {
//        let noPlansAlert = UIAlertController(
//            title: "No Eligible Plans",
//            message: "You don't have any completed plans with friends. Memories can only be posted after accepted plans that have already occurred.",
//            preferredStyle: .alert
//        )
//        noPlansAlert.addAction(UIAlertAction(title: "OK", style: .default))
//        self.present(noPlansAlert, animated: true)
//    }

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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 280, height: 180)
//    }
}

