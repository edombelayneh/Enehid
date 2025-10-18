//
//  StoryDetailsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit

class StoryDetailsViewController: UIViewController {

    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var storyImage: UIImageView!
    
    var story: Story?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.width / 2
        profilePicImage.clipsToBounds = true
        
        usernameLabel.text = story?.ownerId
//        profilePicImage.image = story?.image
//        storyImage.image = story?.story
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
//    */
//    func configure(with story: Story?){
//        
//    }

}
