//
//  PostImageViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class PostImageViewController: UIViewController, UITextFieldDelegate {
    
    var imagePickerImage: UIImage?
    @IBOutlet weak var imageForPosting: UIImageView!
    let dataAccess = DataAccessObject.sharedInstance
    var currentUser: AnyObject?
    @IBOutlet weak var newImgDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageForPosting.image      = imagePickerImage
        self.newImgDescription.delegate = self
        dataAccess.getCurrentUser()
        self.currentUser = dataAccess.currentUser
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func postImageButton(sender: AnyObject) {
        dataAccess.postNewImageForUserId(
            dataAccess.currentUser!.username!,
            userId: currentUser!.objectId!!,
            image: self.imageForPosting!.image!,
            imgDescription: self.newImgDescription!.text!
        )
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
}
