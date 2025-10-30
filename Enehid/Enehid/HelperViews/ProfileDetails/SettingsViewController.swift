//
//  SettingsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/5/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onTappedLogout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            // Navigate to Login or Onboarding
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        } catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
            let alert = UIAlertController(title: "Logout Failed", message: signOutError.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
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
