//
//  ViewController.swift
//  WhatFlower
//
//  Created by Kelvin KUCH on 22.02.2023.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var classificationIdentifier: UINavigationItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageDescription: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        print("classificationIdentifier: \(classificationIdentifier.title!)")
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("[!] Error: unable to convert to CIImage.")
            }
            
            detect(image: ciimage)
        } else {
            print("[!] userPickedImage error.")
        }
        imagePicker.dismiss(animated: true)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true)
    }
    
    func detect(image: CIImage) {
        
        do {
            let model = try VNCoreMLModel(for: FlowerClassifierConvertedFromCaffe().model)
            let request = VNCoreMLRequest(model: model) { (request, error) in
                let classification = request.results?.first as? VNCoreMLFeatureValueObservation
                /*
                 Optional(<VNCoreMLFeatureValueObservation: 0x28014be90> B1752D0E-702F-4952-B90A-CF38C83DF89A VNCoreMLRequestRevision1 confidence=1.000000 "prob" - "MultiArray : Double 1 × 1 × 102 × 1 × 1 array" (1.000000))
                 
                 The classification returns a "MultiArray : Double 1 × 1 × 102 × 1 × 1 array" (amongst other things).
                 The 102 elements of the array are Doubles, which I couldn't make sense of (due to lack of documentation for this ).
                 
                 So, to continue with the tutorial, I decided to use the "prob" for my wiki's API request.
                 */
                
                // ...
                self.classificationIdentifier.title = classification?.featureName
                
                Alamofire.request("https://api.wikimedia.org/core/v1/wikipedia/en/search/title?q=\(classification!.featureName)&limit=1", method: .get).validate().responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print("json: \(json)")
                        self.imageDescription.text = json["pages"][0]["excerpt"].string!
                        
                    case .failure(let error):
                        print("[!] Error: \(error.localizedDescription)")
                    }
                }
                
            }
            
            let ciihandler = VNImageRequestHandler(ciImage: image)
            
            do {
                try ciihandler.perform([request])
            } catch {
                print("[!] Error1: \(error).")
            }
            
        } catch {
            print("[!] Error2 : \(error).")
        }
    }
}
