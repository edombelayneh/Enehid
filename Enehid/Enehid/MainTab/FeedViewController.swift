//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//
//import FirebaseAuth
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    
    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var feedTableView: UITableView!
    
    var post: [Post] = mockPosts
    var story : [Story] = mockStories
    var selectedStory: Story?

    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        
        feedTableView.reloadData()
        storyCollectionView.reloadData()
    }
    
    
    
}

extension FeedViewController: UITableViewDataSource, UICollectionViewDataSource {
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        cell.configure(with: post[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.story.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as? StoryCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: story[indexPath.item])
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStory = story[indexPath.item]
        performSegue(withIdentifier: "ShowStorySegue", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPostSegue" {
            let destinationVC = segue.destination as! PostDetailViewController
            
            // If segue triggered by tapping the entire cell
            if let indexPath = feedTableView.indexPathForSelectedRow {
                let selectedPost = post[indexPath.row]
                destinationVC.post = selectedPost
                print("✅ Passing post to PostVC via cell tap: \(selectedPost)")
            }
        }
        else if segue.identifier == "ShowStorySegue" {
            let destinationVC = segue.destination as! StoryDetailsViewController
            if let selectedStory = selectedStory {
                destinationVC.story = selectedStory
                print("✅ Passing story to StoryDetailVC via cell tap: \(selectedStory)")
            } else {
                print("⚠️ No story selected.")
            }
        }
    }

}

