//
//  PostDetailViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    @IBOutlet weak var selectedPostedImage: UIImageView!
    @IBOutlet weak var selectedPostedImageDescription: UILabel!
    @IBOutlet weak var selectedLikeButton: UIButton!
    var imagePost:          ImagePost?
    var userProfile:        UserProfile?
    let dataAccess  = DataAccessObject.sharedInstance
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCommentArrayCount", name: "retrieveComments", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getLikes", name: "retrieveLikes", object: nil)
        
        let imageUrl:NSURL? = NSURL(string: "\(self.imagePost!.postedImage!.url!)")
        if let url = imageUrl {
            self.selectedPostedImage.sd_setImageWithURL(url)
        }
        dataAccess.getLikersArray(self.selectedLikeButton, imageId: self.imagePost!.imageId!, username: self.imagePost!.username!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedPostedImageDescription.text = self.imagePost?.description
        dataAccess.retrieveCommentsForImageId(id: self.imagePost!.imageId!)
    }
    
    func getCommentArrayCount(){
        self.commentsLabel.text = "\(dataAccess.arrayOfComments.count) Comment(s)"
    }
    
    func getLikes(){
        self.likesLabel.text = "\(dataAccess.arrayOfLikes.count) Like(s)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        print("Like Button Pressed!")
        dataAccess.likeOrUnlikeAPost(self.selectedLikeButton, username: self.imagePost!.username!, imageId: self.imagePost!.imageId!)
        //        if( self.selectedLikeButton.imageView?.image == UIImage(named:"ButtonLikeSelected")) {
        //            self.selectedLikeButton .setImage(UIImage(named:"ButtonLike"), forState: UIControlState.Normal)
        //        } else {
        //            self.selectedLikeButton .setImage(UIImage(named:"ButtonLikeSelected"), forState: UIControlState.Normal)
        //        }
        
        print(dataAccess.arrayOfLikes.count)
        
    }
    
    @IBAction func commentButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showCommentsScreen", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCommentsScreen") {
            if let commentView: CommentsViewController = segue.destinationViewController as? CommentsViewController {
                commentView.imagePost   = self.imagePost!
                commentView.userProfile = self.userProfile!
            }
        }
    }
    
    
}
