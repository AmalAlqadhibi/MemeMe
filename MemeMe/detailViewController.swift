//
//  detailViewController.swift
//  MemeMe
//
//  Created by Amal Alqadhibi on 13/04/2019.
//

import UIKit

class detailViewController: UIViewController {
    // MARK: Variables
    var meme : Meme?
    var memeindex: Int!
    // MARK: Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memeImageView.image = meme?.memedImage
        presentMemeEditorVCRightBarButton()
    }
    
    func presentMemeEditorVCRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(presentMemeEditorVC))
    }
    
    @objc func presentMemeEditorVC() {
        let presentMemeEditorVC = storyboard?.instantiateViewController(withIdentifier: "newMeme") as! MemeEditorView
        presentMemeEditorVC.memeindex = self.memeindex
        present(presentMemeEditorVC, animated: true, completion: nil)    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
