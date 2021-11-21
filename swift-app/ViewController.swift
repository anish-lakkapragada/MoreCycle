//
//  ViewController.swift
//  LEC_Hacks-2021
//
//  Created by Anish Lakkapragada on 11/20/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageViewObject: UIImageView!
    
    @IBOutlet weak var imageDescription: UITextView!
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker=UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        // Do any additional setup after loading the view.
    }

    
    @IBAction func takePic(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageViewObject.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        PictureIdentifyML(image: (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!)
        
    }
    
    func PictureIdentifyML(image:UIImage) {
        guard let model = try? VNCoreMLModel(for:model_1().model) else {
            fatalError("can't load the ml model")
        }
        
        let request = VNCoreMLRequest(model:model) {
            [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                fatalError("cannot get result of VN Request")
            }
            
            DispatchQueue.main.async {
                self?.imageDescription.text = "\(firstResult.identifier), confidence : \(Int(firstResult.confidence * 100))"
            
            }
            
        }
        
        guard let ciImage = CIImage(image:image) else {
            fatalError("some mistake")
        }
        
        let imageHandler = VNImageRequestHandler(ciImage:ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            }
            
            catch {
                print("error")
            }
        }
    }
}

