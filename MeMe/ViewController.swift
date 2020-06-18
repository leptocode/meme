//
//  ViewController.swift
//  MeMe
//
//  Created by Fabio on 5/25/20.
//  Copyright © 2020 Leptocode. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
     
    // MARK: HEADER *******************************************
    
    
    
    
    // MARK: OUTLETS ******************************************
    
    // Top Text
    @IBOutlet weak var topText: UITextField!
    
    // Image
    @IBOutlet weak var imageView: UIImageView!
    
    // Bottom Text
    @IBOutlet weak var bottomText: UITextField!
    
    // MARK: vars
    var memedImage = UIImage()
    var meme:Meme!
    
    var selectedTextField: UITextField?
    
    
    // MARK: CUSTOM DELEGATES ***********************************
    
    let emojiDelegate = EmojiTextFieldDelegate()
    let colorizerDelegate = ColorizerTextFieldDelegate()
    
    // MARK: APP LIFE CYCLE *************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // set top text delegate
        self.topText.delegate = colorizerDelegate
        
        // set bottom text delegate
        self.bottomText.delegate = emojiDelegate
        

        
        
    // keyboard management

    }
    
    func subscribeToKeyboardNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        unsubscribeFromKeyboardNotifications()
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
           if bottomText.isFirstResponder {
               view.frame.origin.y = 0
           }
       }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: TEXT FIELD DELEGATE METODS *************************
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Figure out what the new text will be, if we return true
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        // returning true gives the text field permission to change its text
        return true;
    }
    
    
    // MARK: ACTIONS ********************************************
    
    // Top Text
    @IBAction func topTextEdit(_ sender: Any) {
        
    }
    
    @IBAction func bottomText(_ sender: Any) {
    }
    
    
    
    // Button
    @IBAction func pickImage(_ sender: Any) {

        let imagePickerController = UIImagePickerController()
        // set imagePickerController as delegate
        imagePickerController.delegate = self

        // provide actionSheet to display the camera and photo  options
        let actionSheet = UIAlertController(title: "Source", message: "Take a picture or select a photo", preferredStyle: .actionSheet)

        // add camera action to imagePickerController
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler:{(action:UIAlertAction) in

            // check if the camera is available
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
            }
            else {
                print("Camera not available")
            }

            self.present(imagePickerController, animated: true, completion: nil)
        }))


        // add photos action to imagePickerController
        actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler:{(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
    
            self.present(imagePickerController, animated: true, completion: nil)
        }))


        // cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    
    }
    
    
    // assign image to imageView
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // dismiss the image selector
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    // Bottom text
    @IBAction func bottomTextEdit(_ sender: Any) {

    }
    
    // CREATE MEME *******************************************
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, imageView: imageView.image, memedImage: memedImage)
        self.meme = meme
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
    
    func hideControls() {
        
        
        for view in self.view.subviews as [UIView] {
            if let button = view as? UIButton {
                button.isHidden = true
            }
        }
    }
    
    func showControls() {
        for view in self.view.subviews as [UIView] {
            if let button = view as? UIButton {
                button.isHidden = false
            }
        }
    }

    
    func share() {
        
        
        let memeToShare = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
            
            if success {
                self.save(memedImage: memeToShare)
            }
        }
        present(activity, animated: true, completion:nil)
    }

    
    func generateMemedImage() -> UIImage {

        // Hide toolbar
        
        hideControls()

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage

    }
        
    @IBAction func shareImage(_ sender: Any) {
        
        share()
        
    }

    
}
