//
//  ViewController.swift
//  MyPetIs?
//
//  Created by Muhammad Ilham Ashiddiq Tresnawan on 14/02/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert into CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: PetRCD().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let requestML = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed process image.")
            }
            print(result.first)
            if let firstResult = result.first {
                if firstResult.identifier.contains("Cat"){
                    self.textLabel.text = "is Cat"
                }
                if firstResult.identifier.contains("Dog"){
                    self.textLabel.text = "is a Dog"
                }
                if firstResult.identifier.contains("Rabbit"){
                    self.textLabel.text = "is a rabbit"
                }
            }
            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([requestML])
        }catch{
            print(error)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
}

