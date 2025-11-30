//
//  StoryMediaPickerViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/25/25.
//

import UIKit
import AVFoundation
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//        fetchLatestLibraryThumbnail()
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        fetchLatestLibraryThumbnail()
        
        // Set default icons (system or custom)
        let galleryIcon = UIImage(systemName: "photo.on.rectangle")
        let cameraIcon = UIImage(systemName: "camera.circle")
        
        libraryButton.setImage(galleryIcon, for: .normal)
        captureButton.setImage(cameraIcon, for: .normal)
        
        libraryButton.imageView?.contentMode = .scaleAspectFit
        captureButton.imageView?.contentMode = .scaleAspectFit

    }

    
    func setupCamera() {
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = previewView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            previewView.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        } catch {
            print("Camera error: \(error)")
        }
    }
    @IBAction func onTapCapturePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    @IBAction func onTapOpenLibrary(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func fetchLatestLibraryThumbnail() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let asset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            manager.requestImage(for: asset, targetSize: CGSize(width: 60, height: 60),
                                 contentMode: .aspectFill, options: nil) { image, _ in
                if let image = image {
                    self.libraryButton.setImage(image, for: .normal)
                    self.libraryButton.imageView?.contentMode = .scaleAspectFill
                }
            }
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        goToPreview(with: image)
    }
}

extension CameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { image, error in
            DispatchQueue.main.async {
                if let img = image as? UIImage {
                    self.goToPreview(with: img)
                }
            }
        }
    }
}

extension CameraViewController {
    func goToPreview(with image: UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let previewVC = storyboard.instantiateViewController(identifier: "StoryPreviewViewController") as? StoryPreviewViewController {
            previewVC.selectedImage = image
            self.navigationController?.pushViewController(previewVC, animated: true)
        }
    }
}

