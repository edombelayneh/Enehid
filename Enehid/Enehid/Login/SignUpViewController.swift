//
//  SignUpViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UITextViewDelegate {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsTextView.delegate = self
        
        
        // Do any additional setup after loading the view.
        // Set linked text
        let fullText = "By creating an account, you acknowledge that you have read and agree to Enehid’s Terms and Conditions."
        let attributedString = NSMutableAttributedString(string: fullText)
        let linkRange = (fullText as NSString).range(of: "Terms and Conditions")
        attributedString.addAttribute(.link, value: "enehid://terms", range: linkRange)
        attributedString.addAttributes([
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: linkRange)
        
        
        termsTextView.attributedText = attributedString
        termsTextView.isEditable = false
        termsTextView.isSelectable = true
        termsTextView.dataDetectorTypes = .link
        termsTextView.textAlignment = .left
        termsTextView.font = UIFont.systemFont(ofSize: 14)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        usernameTextField.applyEnehidTFStyle()
        emailTextField.applyEnehidTFStyle()
        passwordTextField.applyEnehidTFStyle()
        
        styleButton()
    }
    
    func styleButton() {
        createAccountButton.layer.cornerRadius = 12
        createAccountButton.clipsToBounds = true
        createAccountButton.layer.shadowColor = UIColor.black.cgColor
        createAccountButton.layer.shadowOpacity = 0.2
        createAccountButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        createAccountButton.layer.shadowRadius = 6
        createAccountButton.layer.masksToBounds = false
    }
    
    @IBAction func onTapAgreed(_ sender: UIButton) {
        isChecked.toggle()
        let imageName = isChecked ? "checkmark.square" : "square"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        createAccountButton.isEnabled = isChecked
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
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: username).getDocuments{ (snapshot, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("❌ Error saving user data: \(error.localizedDescription)")
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self.shake(view: self.usernameTextField)
                self.usernameTextField.becomeFirstResponder()
                let alert = UIAlertController(title: "Username Taken", message: "Please choose a different username.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Sign in if it is a unique username
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
                    
                    let userRef = db.collection("users").document(uid)
                    
                    //                    db.collection("users").document(uid).setData([
                    //                        "username": username,
                    //                        "email": email,
                    //                        "profilePictureUrl": NSNull(),
                    //                        "friends": [:],
                    //                        "incomingRequests": [:],
                    //                        "outgoingRequests": [:],
                    
                    //                    ]) { error in
                    //                        if let error = error {
                    //                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    //                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    //                            self.present(alert, animated: true, completion: nil)
                    //                            print("❌ Error saving user data: \(error.localizedDescription)")
                    //                        }
                    
                    userRef.setData([
                        "username": username,
                        "email": email,
                        "profilePictureUrl": NSNull(),
                        "friends": [:],
                        "incomingRequests": [:],
                        "outgoingRequests": [:]
                    ]) { error in
                        if let error = error {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                            print("❌ Error saving user: \(error.localizedDescription)")
                            return
                        }
                        
                        let defaultSettings: [String: Any] = [
                            "username": username,
                            "preferredCity": "New York",
                            "coordinates": [
                                "lat": 40.7128,
                                "lon": -74.0060
                            ],
                            "preferredRadiusMiles": 10,
                            "notificationsEnabled": true
                        ]
                        
                        userRef.collection("settings").document("preferences").setData(defaultSettings) { error in
                            if let error = error {
                                print("❌ Failed to create default settings: \(error.localizedDescription)")
                            } else {
                                print("✅ Default settings created")
                            }
                            
                            // Continue with navigation
                            let recommendsRef = userRef.collection("recommends").document("placeholder")
                            let starredRef = userRef.collection("starred").document("placeholder")
                            let plannedRef = userRef.collection("plans").document("placeholder")
                            let bookmarkRef = userRef.collection("bookmarked").document("placeholder")
                            
                            
                            recommendsRef.setData(["init": true])
                            starredRef.setData(["init": true])
                            plannedRef.setData(["init": true])
                            bookmarkRef.setData(["init": true])
                            
                            print("✅ User fully initialized")
                            
                            print("✅ User signed up and username saved")
                            // User account created successfully
                            print("User created: \(authResult?.user.email ?? "N/A")")
                            
                            // Go to main app
                            let alert = UIAlertController(title: "Success", message: "Account created successfully!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Enehid", style: .default) { _ in
                                if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                                    tabBarVC.modalPresentationStyle = .fullScreen
                                    self.present(tabBarVC, animated: true)
                                }
                            })
                            self.present(alert, animated: true)
                        }
                        //                    else {
                        //                            let recommendsRef = db.collection("users").document(uid).collection("recommends").document("placeholder")
                        //                            let starredRef = db.collection("users").document(uid).collection("starred").document("placeholder")
                        //                            let plannedRef = db.collection("users").document(uid).collection("plans").document("placeholder")
                        //                            let bookmarkRef = db.collection("users").document(uid).collection("bookmarked").document("placeholder")
                        
                        
                        
                        //                            // Create placeholder documents (optional — remove later)
                        //                            recommendsRef.setData(["init": true])
                        //                            starredRef.setData(["init": true])
                        
                        
                        
                        //                            // Navigate to the next screen or update UI
                        //                            // ✅ Show success alert
                        //                            let alert = UIAlertController(title: "Success", message: "Account created successfully!", preferredStyle: .alert)
                        //                            alert.addAction(UIAlertAction(title: "Enehid", style: .default, handler: { _ in
                        //                                // ✅ Navigate to TabBarController after OK
                        //                                if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                        //                                    tabBarVC.modalPresentationStyle = .fullScreen
                        //                                    self.present(tabBarVC, animated: true, completion: nil)
                        //                                }
                        //                            }))
                        //                            self.present(alert, animated: true, completion: nil)
                        //                        }
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
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, didTapOnLink link: URL, in characterRange: NSRange) {
        openTermsWebView()
    }
    
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        openTermsWebView()
        return false
    }
    
    func openTermsWebView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let termsVC = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as? TermsViewController {
            self.navigationController?.pushViewController(termsVC, animated: true)
        }
    }
    
    
    func shake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }
    
    
}

