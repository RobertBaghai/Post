//
//  ProfileViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userPostLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var profileDescription: UILabel!
    @IBOutlet weak var profileName: UILabel!
    var choosenImageForPosting: UIImage?
    private let reuseIdentifier = "Cell"
    let dataAccess = DataAccessObject.sharedInstance
    let currentUser = DataAccessObject.sharedInstance.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate   = self
        self.collectionView.dataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "observe", name: "getProfileInfo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "post", object: nil)
    }
    
    func update(){
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editProfileButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showEditProfileScreen", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataAccess.getCurrentUser()
        let currentUser = dataAccess.currentUser
        self.navigationItem.title = "\(currentUser!.username!)'s Profile"
        self.userPostLabel.text   = "\(currentUser!.username!)'s Posts"
        dataAccess.getObjectIdToDisplayUserInfo(currentUser!.objectId!)
        dataAccess.retrieveAllImages(currentUser!.objectId!)
    }
    
    func observe(){
        let profile = dataAccess.userProfile
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.profileDescription.text = profile?.usersDescription
            self.profileName.text        = profile?.userProfileName
            self.profileAvatar.image     = profile?.usersAvatar
            print(profile?.usersDescription)
            self.view.reloadInputViews()
        }
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataAccess.arrayOfUserPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PostCollectionViewCell
        
        let name: ImagePost = dataAccess.arrayOfUserPosts[indexPath.row]
        cell.imageCell.image = name.postedImage!
        
        return cell
    }
    
    @IBAction func picturePickerButton(sender: AnyObject) {
        let alertController = UIAlertController.init(title: "Choose a picture to Post!", message: "Would you like to select a photo or take a new one?", preferredStyle: .ActionSheet)
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
        })
        alertController.addAction(cancelAction)
        alertController.addAction(selectPhotoAction)
        alertController.addAction(takePhotoAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.choosenImageForPosting = image
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("showPostDetailScreen", sender: image)
    }
    
    //MARK: CollectionView Delegate
    //     MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if( segue.identifier == "showEditProfileScreen" ){
            if let editProfileView: ProfileDetailViewController = segue.destinationViewController as? ProfileDetailViewController {
                editProfileView.nameText    =  self.profileName!.text!
                editProfileView.descText    =  self.profileDescription!.text!
                editProfileView.avatarImage =  self.profileAvatar!.image
            }
        } else if( segue.identifier == "showPostDetailScreen"){
            if let postPicView: PostImageViewController = segue.destinationViewController as? PostImageViewController {
                print("hey")
                postPicView.imagePickerImage = sender as? UIImage
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
