//
//  RequestsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RequestsViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableViewController: UITableView!
    
    var incomingRequests: [User] = []
    
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewController.delegate = self
        tableViewController.dataSource = self
        
        fetchRequests { users in
            self.incomingRequests = users
            self.tableViewController.reloadData()
            print("R")
            print(users.count)
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
    
    func fetchRequests(completion: @escaping ([User]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("❌ Not logged in Requests")
            completion([])
            return
        }

        db.collection("users").document(currentUID).getDocument { snapshot, error in
            if let error = error {
                print("❌ R Couldn’t fetch: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = snapshot?.data(),
                  let requestMap = data["incomingRequests"] as? [String: String] else {
                print("❌ R No incoming requests")
                completion([])
                return
            }

            // Convert [uid: username] → [User]
            let users: [User] = requestMap.map { (uid, username) in
                return User(id: uid, username: username, email: "")
            }

            completion(users)
        }
    }

    func fetchHangoutCount(for user: User, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let plansRef = db.collection("users").document(user.id).collection("plans")

        plansRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch plans for \(user.username): \(error.localizedDescription)")
                completion(0)
                return
            }

            let count = snapshot?.documents.count ?? 0
            completion(count)
        }
    }

}

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomingRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as? RequestsCell else {
            return UITableViewCell()
        }

        let user = incomingRequests[indexPath.row]
        cell.usernameLabel.text = user.username
        AvatarManager.loadAvatar(from: user.profilePictureURL, into: cell.profilePicImageView)

        cell.bioLabel.text = "Loading hangouts..."

        fetchHangoutCount(for: user) { count in
            DispatchQueue.main.async {
                print("count: \(count)")
                cell.bioLabel.text = count == 0 ? "New to Enehid" : "\(count) hangouts logged"
            }
        }
        
        return cell
        
    }
}
