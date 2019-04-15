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
    var memeindex:Int!
    
    // MARK: Variables
    var memedImage: UIImage?
    let memeTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor : UIColor.white , NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSAttributedString.Key.strokeWidth: -3.0 ]
    var memes:[Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = memeindex == nil ? false : true
        imagePickedView.contentMode = .scaleAspectFit
        self.imagePickedView.contentMode = .scaleAspectFit
        if memeindex != nil {
            configure(topTextField, with: memes[memeindex].topText)
            configure(bottomTextField, with: memes[memeindex].bottomText)
            imagePickedView.image = memes[memeindex].originalImage
        } else {
            configure(topTextField, with: "TOP")
            configure(bottomTextField, with: "BOTTOM")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
 
    //    MARK: IBActions
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // to allow the user to crop the image.
        imagePicker.allowsEditing = true
        imagePicker.sourceType = (sender.tag == 0) ? .photoLibrary : .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        //        to avoid crash when run on an iPad.
        controller.popoverPresentationController?.sourceView = self.view
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // show alert, unsuccessful Recording
                let alertController = UIAlertController(title: "Oops!", message: "Sorry, your meme could not be saved, please try again.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.save()
                // use View Controller Presentation rather thab dismiss , so it will not dismiss to detailVC
                let presentMemeEditorVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
                self.present(presentMemeEditorVC, animated: false, completion: nil)
            } }}
    // MARK: - Helper methods
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func save() {
        if memeindex == nil{
            // Create the meme
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickedView.image!, memedImage: memedImage!)
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        } else {
            (UIApplication.shared.delegate as! AppDelegate).memes[memeindex].memedImage = self.memedImage ?? generateMemedImage()
            (UIApplication.shared.delegate as! AppDelegate).memes[memeindex].topText = self.topTextField.text!
            (UIApplication.shared.delegate as! AppDelegate).memes[memeindex].bottomText = self.bottomTextField.text!
            
        }}
    
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
        // to add editedImage if threr is, or set originalImage
        if let image = info[.editedImage] as? UIImage {
            imagePickedView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            imagePickedView.image = image
        } else{ print("image not found!")}
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    func configureToolBarHidden(_ sender: UIToolbar,isHidden:Bool) {
        sender.isHidden = isHidden
        self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    //MARK: configure textfield
    func configure(_ textField: UITextField, with defaultText: String) {
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self     
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
