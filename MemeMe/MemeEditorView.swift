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
    let memeTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor : UIColor.white , NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSAttributedString.Key.strokeWidth: -3.0 ]
    enum ButtonType:Int {
        case album = 0
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomTextField.delegate = self
        self.topTextField.delegate = self
        shareButton.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        configure(topTextField, with: "TOP")
        configure(bottomTextField, with: "BOTTOM")
        subscribeToKeyboardNotifications()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        if ["TOP", "BOTTOM"].contains(textField.text) {
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
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch ButtonType(rawValue: sender.tag)! {
        case .album :
            imagePicker.sourceType = .photoLibrary
        case .camera:
            imagePicker.sourceType = .camera
        }
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
        } }
    // MARK: - Helper methods
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickedView.image!, memedImage: memedImage!)
    }
    func generateMemedImage() -> UIImage {
        configureToolBarHidden(topToolBar, isHidden: true)
        configureToolBarHidden(bootomToolBar, isHidden: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        configureToolBarHidden(topToolBar , isHidden: false)
        configureToolBarHidden(bootomToolBar , isHidden: false)
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
    func configureToolBarHidden(_ sender: UIToolbar,isHidden:Bool) {
        sender.isHidden = isHidden
        self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    //MARK: configure textfield
    func configure(_ textField: UITextField, with defaultText: String) {
        textField.text = defaultText
          textField.textAlignment = NSTextAlignment.center
        textField.defaultTextAttributes = memeTextAttributes
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
