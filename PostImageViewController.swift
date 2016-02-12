//
//  PostImageViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class PostImageViewController: UIViewController {
    var imagePickerImage: UIImage?
    @IBOutlet weak var imageForPosting: UIImageView!
    let dataAccess = DataAccessObject.sharedInstance
    var currentUser: AnyObject?
    
    @IBOutlet weak var newImgDescription: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageForPosting.image = imagePickerImage
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataAccess.getCurrentUser()
        self.currentUser = dataAccess.currentUser
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func postImageButton(sender: AnyObject) {
        
        dataAccess.postImageForUserId(dataAccess.currentUser!.username!, userId: currentUser!.objectId!!, image: self.imageForPosting!.image!, imgDescription: self.newImgDescription!.text!)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
