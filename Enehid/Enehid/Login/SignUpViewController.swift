//
//  SignUpViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onTappedCreateAccount(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            
            var emptyFields: [UITextField] = []
            
            if emailTextField.text?.isEmpty ?? true {
                emptyFields.append(emailTextField)
            }
            if usernameTextField.text?.isEmpty ?? true {
                emptyFields.append(usernameTextField)
            }
            if passwordTextField.text?.isEmpty ?? true {
                emptyFields.append(passwordTextField)
            }

            // Shake all empty fields
            for field in emptyFields {
                shake(view: field)
            }

            // Focus the first empty field
            emptyFields.first?.becomeFirstResponder()

            // Show alert
            let alert = UIAlertController(
                title: "Error",
                message: "All 3 fields must be filled!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }


        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle specific errors (e.g., weak password, email already in use)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Error creating user: \(error.localizedDescription)")
                return
            } else {
                // User account created successfully
                guard let uid = authResult?.user.uid else { return }
                
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "username": username,
                    "email": email
                ]) { error in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        self.present(alert, animated: true, completion: nil)
                        print("❌ Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("✅ User signed up and username saved")
                        // User account created successfully
                        print("User created: \(authResult?.user.email ?? "N/A")")
                        
                        // Navigate to the next screen or update UI
                        // ✅ Show success alert
                        let alert = UIAlertController(title: "Success", message: "Account created successfully!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Enehid", style: .default, handler: { _ in
                            // ✅ Navigate to TabBarController after OK
                            if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                                tabBarVC.modalPresentationStyle = .fullScreen
                                self.present(tabBarVC, animated: true, completion: nil)
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
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
    func shake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(animation, forKey: "shake")
    }


}
