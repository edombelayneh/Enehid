//
//  TermsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/1/25.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {
    
    
    @IBOutlet weak var termsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Terms & Conditions"
        termsTextView.isEditable = false
        termsTextView.text = termsText
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    let termsText = """
    TERMS AND CONDITIONS – ENEHID
    Effective Date: November 1, 2025

    Welcome to Enehid. By downloading, accessing, or using the Enehid mobile application (the “App”), you agree to the following legally binding Terms and Conditions. If you do not agree, please do not use the App.

    1. ACCEPTANCE OF TERMS
    By creating an account or using Enehid, you affirm that you understand, agree to, and will comply with these Terms and Conditions.
    You also agree not to sue Enehid or any associated parties under any circumstances.

    2. LOCATION DATA
    Enehid relies heavily on location data to function properly. Location information is used to:
    • Discover nearby memories
    • Suggest venues and travel routes
    • Tailor outfit suggestions based on weather and city

    If you deny live location access, Enehid may read embedded photo metadata (EXIF data) to extract approximate location. This is done only to enhance your experience. You can opt out at any time in the app settings.

    3. PHOTO METADATA
    When you upload photos, Enehid may analyze the metadata (e.g., GPS location, timestamp) only if real-time location is unavailable. If location information is found, it may be used to tag your memory for location-based discovery.
    We do not sell or share this metadata.

    4. INTELLECTUAL PROPERTY
    All content, logos, and technology in the app are the property of Enehid and its creator.
    You agree not to copy, distribute, or attempt to reverse-engineer any part of the app.

    5. NO LIABILITY AND NO RIGHT TO SUE
    You explicitly agree to hold Enehid harmless from any and all claims, damages, losses, or liabilities resulting from your use (or inability to use) the app.
    By using this app, you agree not to initiate any legal action or lawsuit against Enehid, its creator, or any associated individuals or entities, for any reason, in any court of law, under any jurisdiction.
    This waiver is absolute and non-negotiable. If you do not agree, do not use the app.

    6. TERMINATION
    Enehid reserves the right to suspend or terminate accounts that violate these terms or misuse the app’s features.

    7. CHANGES TO TERMS
    We may update these Terms from time to time. Continued use of the app after changes means you accept the updated Terms.


    🔐 PRIVACY POLICY – ENEHID
    Effective Date: November 1, 2025

    This Privacy Policy explains how Enehid collects, uses, and protects your information. By using Enehid, you agree to this policy and acknowledge that you cannot sue Enehid under any circumstance.

    1. INFORMATION WE COLLECT
    We collect:
    • Name, email, and profile info (when you sign up)
    • Location data (via GPS or EXIF photo metadata)
    • Memory posts, images, and shared event data
    • Feedback and ratings for events

    2. LOCATION & METADATA
    Your location helps us:
    • Show nearby memories and venues
    • Recommend activities
    • Tailor fashion suggestions to weather and city

    If you deny real-time location, we may access location from photo metadata (EXIF) only when you upload a photo, and only to support core features. You can disable this in settings.

    3. DATA USE
    We use your data to:
    • Provide core app features
    • Personalize your experience
    • Improve app performance

    We do not sell your personal data or metadata to third parties. Ever.

    4. YOUR CONTROL
    You can:
    • Edit or delete your profile and memories
    • Revoke location or metadata access
    • Request full data deletion by contacting us

    5. NO LAWSUITS OR LEGAL ACTION
    By using Enehid, you completely waive your right to pursue legal action against Enehid, its creator, developers, partners, or affiliates.
    You agree not to sue, make claims, or seek damages of any kind.

    This includes (but is not limited to):
    • Data loss or exposure
    • App malfunctions
    • Feature changes
    • Account termination

    If you disagree, do not use Enehid.

    6. SECURITY
    We use Firebase Authentication and Firebase Storage, encrypted where possible, to keep your data secure.

    7. CHANGES TO POLICY
    We may update this Privacy Policy at any time. Continued use of the app implies acceptance.

    8. CONTACT
    For questions or data removal requests, please contact:
    Edom Belayneh
    Creator of Enehid
    Email: belayneh1ey@gmail.com
    LinkedIn: linkedin.com/in/edombelayneh
    """

}

