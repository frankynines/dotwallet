//
//  CreateCollectibleViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 9/18/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CreateCollectibleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mint Collectible"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let leftButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(iba_dismiss))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func iba_dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iba_selectImage(){
        
        let alert = UIAlertController(title: "Choose Image", message: "Upload Image to Add as your new token", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.chooseCameraWith(type: .photoLibrary)
        })
        alert.addAction(photoLibraryAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.chooseCameraWith(type: .camera)
        })
        alert.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: {() -> Void in
        })
        
    }
    
    func chooseCameraWith(type:UIImagePickerController.SourceType){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = type
        self.present(imagePickerController, animated: true, completion: nil)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_InputScreenPageViewController") as! InputScreenPageViewController
            vc.userImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            vc.inputLabel = "Name your Item"
            vc.key = "name"
            vc.tag = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
