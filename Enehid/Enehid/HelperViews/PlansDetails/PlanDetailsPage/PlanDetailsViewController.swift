//
//  PlanDetailsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/9/25.
//

import UIKit

class PlanDetailsViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityNameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var plan: Plans?
    var participantsBySection: [ParticipantSection: [Participant]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupParticipantsBySection()
        
        collectionView.collectionViewLayout = createLayout()
        
        //        registerCollectionView()
        
                collectionView.dataSource = self
                collectionView.delegate = self
        
        activityNameLabel.text = plan?.activityName
        dateLabel.text = plan?.date
        //        timeLabel.text = plan?.date
        locationLabel.text = plan?.location
        
//        
//        collectionView.register(
//            UINib(nibName: "SectionHeaderView", bundle: nil),
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "SectionHeaderView"
//        )
        
        
        
        // Do any additional setup after loading the view.
        collectionView.reloadData()

    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //    func registerCollectionView() {
    //        collectionView.register(
    //            UINib(nibName: "ParticipantCell", bundle: nil),
    //            forCellWithReuseIdentifier: "ParticipantCell"
    //        )
    //
    //    }
    
    
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
            let sectionType = ParticipantSection.allCases[sectionIndex]
            
            // Item (ParticipantCell)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(60),
                heightDimension: .absolute(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(90)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(12)
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
            
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
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
        case .accepted: return "Accepted"
        case .pending: return "Pending"
        case .declined: return "Declined"
        }
    }
}


