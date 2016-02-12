//
//  ProfileDetailViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let dataAccess = DataAccessObject.sharedInstance
    @IBOutlet weak var newProfileNameText: UITextField!
    @IBOutlet weak var newProfileDescriptionText: UITextField!
    @IBOutlet weak var newProfileAvatarImage: UIImageView!
    
    var nameText:String?
    var descText:String?
    var avatarImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataAccess.getCurrentUser()
        self.newProfileNameText.delegate        = self
        self.newProfileDescriptionText.delegate = self
        self.newProfileNameText.text            = self.nameText
        self.newProfileDescriptionText.text     = self.descText
        self.newProfileAvatarImage.image        = self.avatarImage
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changePictureButton(sender: AnyObject) {
        
        let alertController = UIAlertController.init(title: "Choose a new Profile Picture", message: "Would you like to select a photo or take a new one?", preferredStyle: .ActionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: {action -> Void in
                //Just dismiss action sheet
        })
        let selectPhotoAction: UIAlertAction = UIAlertAction(title: "Select Photo", style: .Default, handler: {action -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let takePhotoAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {action -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
            
            
            //            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
            //                message:@"Device has no camera"
            //                delegate:nil
            //                cancelButtonTitle:@"Okay"
            //                otherButtonTitles: nil];
            //                [myAlertView show];
            //            }
            //            else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            //                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            //                picker.delegate = self;
            //                picker.allowsEditing = YES;
            //                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //                [self presentViewController:picker animated:YES completion:NULL];
            //            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(selectPhotoAction)
        alertController.addAction(takePhotoAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.newProfileAvatarImage.image = image
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitNewProfileInfoButton(sender: AnyObject) {
        let newimage = self.newProfileAvatarImage.image
        print("\(dataAccess.currentUser!.objectId!)")
        dataAccess.getObjectIdFromUserProfileParseClassForUser("\(dataAccess.currentUser!.objectId!)", name: self.newProfileNameText.text!, details: self.newProfileDescriptionText.text!, avatar: newimage!)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
}