//
//  PlansViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PlansViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var plansTableView: UITableView!
    
    
    var plans: [Plans] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plansTableView.delegate = self
        plansTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        fetchPlans{ plansUpdate in
            self.plans = plansUpdate
            self.plansTableView.reloadData()
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
    
    func fetchPlans(completion: @escaping ([Plans]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        let plansRef = db.collection("users").document(currentUID).collection("plans")
        
        plansRef.getDocuments(source: .default) { snapshot, error in
            if let error = error {
                print("❌ Failed to get plans: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let docs = snapshot?.documents else {
                print("📭 No plans found")
                completion([])
                return
            }
            
            let planIds = docs.compactMap { $0.data()["planId"] as? String }
            var plans: [Plans] = []
            let dispatchGroup = DispatchGroup()
            
            for planId in planIds {
                dispatchGroup.enter()
                db.collection("plans").document(planId).getDocument(source: .default) { planSnapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        print("❌ Failed to get plan for \(planId): \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = planSnapshot?.data() else {
                        return
                    }
                    
                    let acceptedByList = data["acceptedByIDs"] as? [String] ?? []
                    let declinedByList = data["declinedByIDs"] as? [String] ?? []
                    let currentUID = Auth.auth().currentUser?.uid ?? ""
                    
                    let plan = Plans(
                        id: planSnapshot!.documentID,
                        activityName: data["activityName"] as? String ?? "",
                        location: data["location"] as? String ?? "",
                        date: data["date"] as? String ?? "",
                        group: data["group"] as? String ?? "",
                        createdBy: data["createdBy"] as? String ?? "",
                        participants: data["participants"] as? [String:String] ?? [:],
                        acceptedByIDs: Set(acceptedByList),
                        declinedByIDs: Set(declinedByList),
                        iAccepted: acceptedByList.contains(currentUID)
                    )
                    
                    plans.append(plan)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(plans)
            }
            
        }
    }
}


extension PlansViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plan = plans[indexPath.row]
        let id = plan.createdByIsMe ? "PlanOwnerCell" : "PlanInviteeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! PlansCell
    
        cell.activityNameLabel.text = plan.activityName
        cell.locationLabel.text     = plan.location
        cell.dateLabel.text         = plan.date
        cell.createdBy.text    = plan.createdByIsMe ? "Organizer: YOU"
        : "@\(plan.createdBy)"
        print("🫵🏽\(plan.activityName) is_me \(plan.createdByIsMe)")
        
        if plan.createdByIsMe {
            cell.ownerControlsView?.isHidden  = false
            cell.inviteeStatusView?.isHidden  = true
            cell.acceptButton?.isHidden       = true
            cell.declineButton?.isHidden      = true
            cell.waitingLabel?.text            = "\(plan.acceptedCount)/\(plan.totalCount) friends accepted"
        } else {
            cell.ownerControlsView?.isHidden  = true
            cell.inviteeStatusView?.isHidden  = false
            cell.acceptButton?.isHidden       = plan.iAccepted
            cell.declineButton?.isHidden      = !plan.iAccepted
            cell.waitingLabel?.text           = plan.iAccepted ? "You accepted" : "Waiting on you"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plan = plans[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "PlanDetailsViewController") as! PlanDetailsViewController
//        detailVC.plan = plan
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
}
