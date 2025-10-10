//
//  PostDetailViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit

class PostDetailViewController: UIViewController {

    
    
    @IBOutlet weak var addToBookmarkButton: UIButton!
    @IBOutlet weak var showOnMapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var addToPlansButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var post: Post?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        captionLabel.text = post?.caption
        usernameLabel.text = post?.username
        postImage.image = post?.image
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
