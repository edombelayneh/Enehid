//
//  NewPlanViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/29/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewPlanViewController: UIViewController {

    @IBOutlet weak var scheduleButton: UIButton!
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var activityName: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onTappedSchedule(_ sender: UIButton) {
//        var activityName = activityName.text ?? "Unknown"
//        guard var location = locationTextField.text else { return "Unknown" }
//        createPlan(activityName: activityName, location: location, date: <#T##String#>, participants: <#T##[String : String]#>)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func createPlan(activityName: String, location: String, date: String, participants: [String: String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let planRef = db.collection("plans").document()
        let planId = planRef.documentID
        
        let data: [String: Any] = [
            "activityName": activityName,
            "location": location,
            "date": date,
            "group": "default", // optional
            "createdBy": uid,
            "participants": participants,
            "acceptedByIDs": []
        ]
        
        // Write to plans
        planRef.setData(data) { error in
            if let error = error {
                print("❌ Error creating plan: \(error)")
                return
            }

            // Add plan ref to each participant
            for participantUID in participants.keys {
                db.collection("users").document(participantUID)
                  .collection("plans").document(planId)
                  .setData(["planId": planId])
            }
        }
    }


}
