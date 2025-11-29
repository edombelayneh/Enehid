//
//  PlansViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PlansViewController: RefreshableViewController, UITableViewDelegate {
    
    @IBOutlet weak var plansTableView: UITableView!
    
    enum PlanSection: Int, CaseIterable {
        case upcoming
        case pending
        case past

        var title: String {
            switch self {
            case .upcoming: return "UPCOMING"
            case .pending: return "PENDING"
            case .past: return "PAST"
            }
        }
    }

    var sectionedPlans: [PlanSection: [Plans]] = [:]
    var plans: [Plans] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plansTableView.delegate = self
        plansTableView.dataSource = self
        // Do any additional setup after loading the view.
        plansTableView.sectionHeaderHeight = 20
        //        plansTableView.separatorStyle = .none
        //        plansTableView.backgroundColor = UIColor.systemGroupedBackground
        plansTableView.contentInset.bottom = 20
        plansTableView.register(PlanCell.self, forCellReuseIdentifier: "PlanCell")
        
        fetchPlans()

        plansTableView.reloadData()
        
    }
    
    override func handleRefresh() {
        print("🔁 PlansViewController refreshing...")

        sectionedPlans = [:]
        plansTableView.reloadData()

        fetchPlans()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.endRefreshing()
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
    
    var listener: ListenerRegistration?

    func fetchPlans() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        let userPlansRef = db.collection("users").document(currentUID).collection("plans")

        // Remove previous listener if re-fetching
        listener?.remove()

        listener = userPlansRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Failed to get plans: \(error.localizedDescription)")
                return
            }

            guard let docs = snapshot?.documents else {
                print("📭 No plans found")
                return
            }

            var allPlans: [Plans] = []
            let dispatchGroup = DispatchGroup()

            for doc in docs {
                let planId = doc.documentID
                let status = doc.data()["status"] as? String ?? "pending"

                dispatchGroup.enter()
                db.collection("plans").document(planId).getDocument { planSnapshot, error in
                    defer { dispatchGroup.leave() }

                    guard let data = planSnapshot?.data() else { return }

                    let acceptedByList = data["acceptedByIDs"] as? [String] ?? []
                    let declinedByList = data["declinedByIDs"] as? [String] ?? []

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
                        iAccepted: status == "accepted",
                        iDeclined: status == "declined"
                    )

                    allPlans.append(plan)
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.sortAndDisplayPlans(allPlans)
            }
        }
    }
    
    private func sortAndDisplayPlans(_ plans: [Plans]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        var upcoming: [Plans] = []
        var pending: [Plans] = []
        var past: [Plans] = []

        for plan in plans {
            guard let planDate = formatter.date(from: plan.date) else { continue }

            if plan.iAccepted {
                if planDate >= Date() {
                    upcoming.append(plan)
                } else {
                    past.append(plan)
                }
            } else if !plan.iDeclined {
                pending.append(plan)
            }
        }

        upcoming.sort { $0.date < $1.date }
        past.sort { $0.date > $1.date }

        self.sectionedPlans = [
            .upcoming: upcoming,
            .pending: pending,
            .past: past
        ]

        self.plansTableView.reloadData()
    }
    
    deinit {
        listener?.remove()
    }
    
}


extension PlansViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return PlanSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = PlanSection(rawValue: section)!
        return sectionedPlans[sectionType]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = PlanSection(rawValue: section)
        return sectionType?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = PlanSection(rawValue: indexPath.section)!
        let plan = sectionedPlans[sectionType]![indexPath.row]
        
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
        let sectionType = PlanSection(rawValue: indexPath.section)!
        let plan = sectionedPlans[sectionType]![indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "PlanDetailsViewController") as! PlanDetailsViewController
        detailVC.plan = plan
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let spacing: CGFloat = 15
        let insets = UIEdgeInsets(top: spacing, left: 16, bottom: spacing, right: 16)
        cell.contentView.frame = cell.contentView.frame.inset(by: insets)
        
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = .clear
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
                print("✅ Updated plan response")
                
                // 🔽 NEW: Update participant status in groupChat
                let chatQuery = db.collection("groupChats").whereField("planId", isEqualTo: plan.id)
                chatQuery.getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents, let chatDoc = docs.first else {
                        print("❌ No group chat found for plan \(plan.id)")
                        return
                    }
                    
                    let groupChatId = chatDoc.documentID
                    let participantPath = "participants.\(uid).status"
                    
                    db.collection("groupChats").document(groupChatId).updateData([
                        participantPath: accept ? "accepted" : "invited"
                    ]) { error in
                        if let error = error {
                            print("❌ Failed to update chat status: \(error)")
                        } else {
                            print("✅ Chat participant status updated to \(accept ? "accepted" : "invited")")
                        }
                    }
                }
                self.fetchPlans()
            }
        }
        
    }
    
    
}


