//
//  AvatarManager.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/31/25.
//

import UIKit
import FirebaseStorage

class AvatarManager {
    
    static func loadAvatar(from urlString: String?, into imageView: UIImageView, cropToFace: Bool = true) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("⚠️ Invalid URL. Using placeholder.")
            imageView.image = UIImage(systemName: "person")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching avatar: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "avatar_placeholder")
                    applyCrop(to: imageView, cropToFace: cropToFace)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode image. Using placeholder.")
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "avatar_placeholder")
                    applyCrop(to: imageView, cropToFace: cropToFace)
                }
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
                imageView.layoutIfNeeded() // ✅ <-- this matters
                applyCrop(to: imageView, cropToFace: cropToFace)
            }
        }.resume()
    }
    
    private static func applyCrop(to imageView: UIImageView, cropToFace: Bool) {
        imageView.layoutIfNeeded() // ✅ Ensure frame is available
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        // Optional: Add border
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.softPurple.cgColor
        
        // ❌ Remove contentsRect and transform
        // Cropping must be done on the image, not the layer
        if cropToFace {
            imageView.layer.contentsGravity = .resizeAspectFill
            imageView.layer.contentsRect = CGRect(x: -0.01, y: 0.15, width: 1, height: 0.35) // Adjust crop (middle section)
            imageView.transform = CGAffineTransform(scaleX: 1, y: 1) // Adjust scale as needed
        } else {
            imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
    
}
