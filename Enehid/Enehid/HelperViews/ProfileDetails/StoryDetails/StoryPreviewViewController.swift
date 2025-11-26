//
//  StoryViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/25/25.
//

import UIKit
import PhotosUI

class StoryPreviewViewController: UIViewController {
    
    @IBOutlet weak var storyImageView: UIImageView!
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        storyImageView.image = selectedImage
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapAddToStory(_ sender: UIButton) {
        guard var image = selectedImage else { return }
        
        // TODO: Upload to Firebase or save to model
        print("Story Added!")
        
        
        
        let alert = UIAlertController(title: "Added!", message: "Your story has been added.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

