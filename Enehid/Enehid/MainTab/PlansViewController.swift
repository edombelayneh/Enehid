//
//  PlansViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit

class PlansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plan = plans[indexPath.row]
        let id = plan.createdByIsMe ? "PlanOwnerCell" : "PlanInviteeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! PlansCell

        // Common fields
//        cell.profileUIImageVIew.image = UIImage.enehidLogo
        cell.activityNameLabel.text = plan.activityName
        cell.locationLabel.text     = plan.location
        cell.dateLabel.text         = plan.date
        cell.createdBy.text    = plan.createdByIsMe ? "Organizer: YOU"
                                                             : "@\(plan.createdBy)"

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

//            cell.onAccept = { [weak self] in /* update model + reload row */ }
//            cell.onDecline = { [weak self] in /* update model + reload row */ }
        }

        return cell
    }
    

    @IBOutlet weak var plansTableView: UITableView!
    
    
    var plans: [Plans] = mockPlans
    override func viewDidLoad() {
        super.viewDidLoad()
        plansTableView.delegate = self
        plansTableView.dataSource = self
        // Do any additional setup after loading the view.
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
