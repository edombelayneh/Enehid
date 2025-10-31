//
//  LoginViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore



class LoginViewController: UIViewController, UITextFieldDelegate {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    @IBAction func onTappedLogin(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter both username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: username)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching user: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "Username not found.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    present(alert, animated: true)
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                let userData = documents[0].data()
                guard let email = userData["email"] as? String else {
                    let alert = UIAlertController(title: "Error", message: "Could not retrieve email for user.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    present(alert, animated: true)
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                // Step 2: Sign in with retrieved email and password
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        let alert = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
//                        present(alert, animated: true)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    print("✅ User logged in: \(email)")
                    // Navigate to your main app (e.g., TabBarController)
                    if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                        tabBarVC.modalPresentationStyle = .fullScreen
                        self.present(tabBarVC, animated: true)
                    }
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }
    


}
