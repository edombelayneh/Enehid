//
//  LoginViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTappedLogin(_ sender: UIButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
            } else {
                print("User logged in: \(authResult?.user.username ?? "")")
                // Perform segue or show main screen
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
