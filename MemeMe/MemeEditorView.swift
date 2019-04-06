//
// MemeEditorView.swift
//  MemeMe
//
//  Created by Amal Alqadhibi on 29/03/2019.
//

import UIKit

class MemeEditorView: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{
    // MARK: Outlets
    @IBOutlet weak var imagePickedView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bootomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    // MARK: Variables
    var memedImage: UIImage?
    struct Meme {
        let topText:String
        let bottomText:String
        var originalImage:UIImage
        var memedImage:UIImage
    }
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor : UIColor.white , NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSAttributedString.Key.strokeWidth: -3.0 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.textAlignment = NSTextAlignment.center
        topTextField.text = "TOP"
        bottomTextField.text =  "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.center
        self.bottomTextField.delegate = self
        self.topTextField.delegate = self
        shareButton.isEnabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        subscribeToKeyboardNotifications()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        if topTextField.text == "TOP" && textField == topTextField {
            textField.text = ""
        } else if bottomTextField.text == "BOTTOM" && textField == bottomTextField {
            textField.text = ""
        }
    }
// to avoid nil textfield so it makes it easier for the user to find it
    func textFieldDidEndEditing(_ textField: UITextField){
        if topTextField.text == "" && textField == topTextField {
            textField.text = "TOP"
        } else if bottomTextField.text == "" && textField == bottomTextField {
            textField.text = "BOTTOM"
        }
    }
    
    //    MARK: IBActions
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func PickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let memeImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        //        to avoid crash when run on an iPad.
        controller.popoverPresentationController?.sourceView = self.view
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self.dismiss(animated: true, completion: nil)
            }
            self.memedImage = self.generateMemedImage()
            self.save()
        }
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickedView.image!, memedImage: memedImage!)
    }
    func generateMemedImage() -> UIImage {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.topToolBar.isHidden = true
        bootomToolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        topToolBar.isHidden = false
        bootomToolBar.isHidden = false
        return memedImage
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagePickedView.contentMode = .scaleAspectFit
            imagePickedView.image = image
            shareButton.isEnabled = true
            dismiss(animated: true, completion: nil)
        } else{ print("image not found!")}
    }
    
    // MARK: Move view functions
    @objc func keyboardWillShow(_ notification: Notification){
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    // Functions for get size of user keyboard to move it
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self , selector: #selector(keyboardWillShow(_:)) , name: UIResponder.keyboardWillShowNotification , object : nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    // MARK:  move the view back down when the keyboard is dismissed
    @objc   func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
}
