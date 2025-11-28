//
//  PlanDetailsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/9/25.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore

class PlanDetailsViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var plan: Plans?
    var participantsBySection: [ParticipantSection: [Participant]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupParticipantsBySection()
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        activityNameLabel.text = plan?.activityName
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        if let dateString = plan?.date, let dateObj = inputFormatter.date(from: dateString) {
            dateLabel.text = dateFormatter.string(from: dateObj) // e.g., "Nov 21, 2025"
            timeLabel.text = timeFormatter.string(from: dateObj) // e.g., "2:30 PM"
        } else {
            dateLabel.text = plan?.date
            timeLabel.text = ""
        }
        
        locationLabel.text = plan?.location
                
        // Do any additional setup after loading the view.
        collectionView.reloadData()
        
        collectionView.layer.cornerRadius = 16
        collectionView.clipsToBounds = true
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.systemGray4.cgColor

        // Shadow
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 0.15
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        collectionView.layer.shadowRadius = 8
        setupMap()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func setupParticipantsBySection() {
        guard let plan = plan else { return }
        
        participantsBySection[.accepted] = plan.participantsByStatus[.accepted] ?? []
        participantsBySection[.pending] = plan.participantsByStatus[.pending] ?? []
        participantsBySection[.declined] = plan.participantsByStatus[.declined] ?? []
        
        print("✅ Accepted: \(participantsBySection[.accepted]?.count ?? 0)")
        print("⏳ Pending: \(participantsBySection[.pending]?.count ?? 0)")
        print("❌ Declined: \(participantsBySection[.declined]?.count ?? 0)")
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            //            let sectionType = ParticipantSection.allCases[sectionIndex]
            
            // Item (ParticipantCell)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(80),
                heightDimension: .absolute(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(90),
                heightDimension: .absolute(60)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(12)
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
            
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(10)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.interGroupSpacing = 10
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
    }
    
    func setupMap() {
        guard let plan = plan else { return }
        
        let location = CLLocationCoordinate2D(latitude: plan.lat, longitude: plan.lon)
        
        // Center the map
        let region = MKCoordinateRegion(center: location,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        // Add a pin annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = plan.location
        mapView.addAnnotation(annotation)
        
        // Rounded corners
        mapView.layer.cornerRadius = 16
        mapView.clipsToBounds = true // Important for shadows to show

        // Border
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = UIColor.systemGray4.cgColor

        // Shadow
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowOpacity = 0.4
        mapView.layer.shadowOffset = CGSize(width: 0, height: 4)
        mapView.layer.shadowRadius = 8
    }
    
    
    
}

extension PlanDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ParticipantSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = ParticipantSection.allCases[section]
        return participantsBySection[sectionType]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = ParticipantSection.allCases[indexPath.section]
        let participant = participantsBySection[sectionType]?[indexPath.row]
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
        cell.usernameLabel.text = participant?.name
        
        if let participantId = participant?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(participantId).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching participant user: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data(),
                      let profileURL = data["profilePictureURL"] as? String else {
                    print("No profilePictureURL found for participant \(participantId)")
                    return
                }

                AvatarManager.loadAvatar(from: profileURL, into: cell.profilePictureImageView)
            }
        }

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath) as! SectionHeaderView
            
            let sectionType = ParticipantSection.allCases[indexPath.section]
            header.titleLabel.text = sectionType.title
            return header
        }
        return UICollectionReusableView()
    }
    
}

enum ParticipantSection: Int, CaseIterable {
    case accepted, pending, declined
    
    var title: String {
        switch self {
        case .accepted: return "ACCEPTED"
        case .pending: return "PENDING"
        case .declined: return "DECLINED"
        }
    }
}


