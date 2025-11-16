//
//  FirendPickerViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/16/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FriendPickerViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //    var allFriends: [Friend] = []
    //    var selectedFriends: Set<String> = [] // uids
    var allFriends: [User] = []
    var selectedFriends: Set<String> = []
    
    var onSelectionComplete: (([User]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        UserService.shared.fetchFriends { [weak self] friends in
            self?.allFriends = friends
            self?.tableView.reloadData()
        }
    }
    
    
    @IBAction func onTappedDone(_ sender: UIButton) {
        let selected = allFriends.filter { selectedFriends.contains($0.id) }
        onSelectionComplete?(selected)
        dismiss(animated: true)
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

extension FriendPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = allFriends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "FriendCell")
        
        cell.textLabel?.text = user.username
        cell.imageView?.image = UIImage(named: "default_avatar") // or load remote
        
        cell.accessoryType = selectedFriends.contains(user.id) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = allFriends[indexPath.row]
        
        if selectedFriends.contains(friend.id) {
            selectedFriends.remove(friend.id)
        } else {
            selectedFriends.insert(friend.id)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
