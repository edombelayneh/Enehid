//
//  MediaPickerViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/1/25.
//

import UIKit
import PhotosUI

class MediaPickerViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentPhotoPicker()
    }

    func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 // Max number of selections
        config.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension MediaPickerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let itemProviders = results.map { $0.itemProvider }
        let total = itemProviders.count

        for provider in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedImages.append(image)
                            if self.selectedImages.count == total {
                                self.goToNextStep()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func goToNextStep() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NewMemoryVC") as? NewMemoryViewController {
            vc.selectedImages = self.selectedImages
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
