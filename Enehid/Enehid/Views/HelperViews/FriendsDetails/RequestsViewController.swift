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
            print("❌ Not logged in R")
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

    

}

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomingRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as? RequestsCell else {
            return UITableViewCell()
        }
        print(cell.usernameLabel)

        
        return cell
        
    }
}
