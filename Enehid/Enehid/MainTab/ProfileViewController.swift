//
//  PlansViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//


import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBAction func didTapBookmarked(_ sender: Any) {
        performSegue(withIdentifier: "BookmarkedSegue", sender: nil)
    }
    @IBAction func didTapAddStory(_ sender: Any) {
    }
    @IBAction func didTapSettings(_ sender: Any) {
        performSegue(withIdentifier: "SettingsSegue", sender: nil)
    }
    @IBAction func didChangeTabsSegmentedControl(_ sender: UISegmentedControl) {
        // This is called when the user taps one of the tabs.
        let target = sender.selectedSegmentIndex
        let selectedIndex = sender.selectedSegmentIndex
        guard target != currentIndex else { return }
//        let viewControllerToShow = orderedViewControllers[selectedIndex]
        
        // We set the correct direction for the transition.
        let direction: UIPageViewController.NavigationDirection = (target >  currentIndex) ? .forward : .reverse
        let vc = orderedViewControllers[target]
        pageViewController.setViewControllers([vc], direction: direction, animated: true) {[weak self] _ in self?.currentIndex = target}
    }
    
    @IBOutlet weak var postSegmentedControl: UISegmentedControl!
    @IBOutlet weak var recommendsCounterLabel: UILabel!
   
    @IBOutlet weak var starsCounterLabel: UILabel!
    @IBOutlet weak var memoriesCounterLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    private var pageViewController: UIPageViewController!
    private var currentIndex = 0
    
    private lazy var orderedViewControllers: [UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let memoriesVC = sb.instantiateViewController(withIdentifier: "MemoriesVC")
        let starsVC = sb.instantiateViewController(withIdentifier: "StarsVC")
        let reviewsVC = sb.instantiateViewController(withIdentifier: "ReviewsVC")
        
        return [memoriesVC, starsVC, reviewsVC]
    }()
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    func fetchUser(completion: @escaping (User?) -> Void) {
        self.db.collection("users").document(self.currentUID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("User not found")
                completion(nil)
                return
            }
            
            let user = User (
                id: self.currentUID,
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? "",
                profilePictureURL: data["profilePictureURL"] as? String,
                friends: data["friends"] as? [String:String] ?? [:],
            )
            
            completion(user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        
        // Do any additional setup after loading the view.
        fetchUser { user in
            guard let user = user else { return }
            DispatchQueue.main.async {
                self.usernameLabel.text = user.username
                self.memoriesCounterLabel.text = "\(user.friends.count)"
                AvatarManager.loadAvatar(from: user.profilePictureURL, into: self.profilePicImageView)
                print("👀 Loading avatar from: \(user.profilePictureURL ?? "nil")")
            }
        }
        postSegmentedControl.selectedSegmentIndex = 0
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditAvatarViewController") as? EditAvatarViewController {
            navigationController?.pushViewController(editVC, animated: true)
        }
    }

    // MARK: - Setup
    private func setupPageViewController() {
        // 1. Initialize the page view controller.
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.dataSource = self // This is needed to enable swiping.
        pageViewController.delegate = self
        
        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
        pageViewController.setViewControllers([orderedViewControllers[0]], direction: .forward, animated:false)
    }


}

extension ProfileViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let idx = orderedViewControllers.firstIndex(of: vc), idx > 0 else { return nil }
        return orderedViewControllers[idx - 1]
    }

    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let idx = orderedViewControllers.firstIndex(of: vc), idx < orderedViewControllers.count - 1 else { return nil }
        return orderedViewControllers[idx + 1]
    }
}

extension ProfileViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        guard completed, let visible = pvc.viewControllers?.first,
              let idx = orderedViewControllers.firstIndex(of: visible) else { return }
        currentIndex = idx
        postSegmentedControl.selectedSegmentIndex = idx
    }
}
