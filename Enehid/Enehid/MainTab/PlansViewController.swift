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
        plansTableView.register(PlanCell.self, forCellReuseIdentifier: "PlanCell")

        fetchPlans{ plansUpdate in
            self.plans = plansUpdate
            self.plansTableView.reloadData()
        }
        plansTableView.reloadData()
        
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
        let userPlansRef = db.collection("users").document(currentUID).collection("plans")
        
        userPlansRef.getDocuments(source: .default) { snapshot, error in
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
            
            var plans: [Plans] = []
            let dispatchGroup = DispatchGroup()
            
            for doc in docs {
                let planId = doc.documentID
                let status = doc.data()["status"] as? String ?? "pending"
                
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
                        createdBy: data["createdBy"] as? String ?? "",
                        lat: data["lat"] as? Double ?? 0.0,
                        lon: data["lon"] as? Double ?? 0.0,
                        participants: data["participants"] as? [String: String] ?? [:],
                        acceptedByIDs: Set(acceptedByList),
                        declinedByIDs: Set(declinedByList),
                        iAccepted: status == "accepted", // pulled from user doc
                        iDeclined: status == "declined"
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
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        let plan = plans[indexPath.row]
//        let id = plan.createdByIsMe ? "PlanOwnerCell" : "PlanInviteeCell"
//        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! PlansCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as! PlanCell
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        cell.configure(with: plan, currentUserId: currentUserId)
        cell.onAccept = { [weak self] in
            self?.handleResponse(to: plan, accept: true)
        }
        cell.onDecline = { [weak self] in
            self?.handleResponse(to: plan, accept: false)
        }

        // ✅ Always set these core labels
        cell.activityLabel.text = plan.activityName
        cell.locationLabel.text     = plan.location
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium  // e.g., "Nov 21, 2025"
        outputFormatter.timeStyle = .none

        if let dateObj = inputFormatter.date(from: plan.date) {
            cell.dateLabel.text = outputFormatter.string(from: dateObj)
        } else {
            cell.dateLabel.text = plan.date // fallback if parsing fails
        }


        // ✅ Show who scheduled it
        if plan.createdByIsMe {
            cell.createdByLabel.text = "Scheduled by You"
        } else {
            if let name = plan.participants[plan.createdBy] {
                print("Here is name: \(name)")
                cell.createdByLabel.text = "@\(name)"
            } else {
                cell.createdByLabel.text = "@\(plan.createdBy.prefix(5))"
            }
        }
        

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plan = plans[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "PlanDetailsViewController") as! PlanDetailsViewController
        detailVC.plan = plan
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    func handleResponse(to plan: Plans, accept: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        // Update central plans collection
        let planRef = db.collection("plans").document(plan.id)
        let fieldToUpdate = accept ? "acceptedByIDs" : "declinedByIDs"
        let oppositeField = accept ? "declinedByIDs" : "acceptedByIDs"

        let batch = db.batch()
        batch.updateData([
            fieldToUpdate: FieldValue.arrayUnion([uid]),
            oppositeField: FieldValue.arrayRemove([uid])
        ], forDocument: planRef)

        // Update user's own subcollection
        let userPlanRef = db.collection("users").document(uid).collection("plans").document(plan.id)
        batch.updateData([
            "status": accept ? "accepted" : "declined"
        ], forDocument: userPlanRef)

        batch.commit { error in
            if let error = error {
                print("❌ Failed to update response: \(error)")
            } else {
                print("✅ Updated response")
                self.fetchPlans { updated in
                    self.plans = updated
                    self.plansTableView.reloadData()
                }
            }
        }
    }

    
}
