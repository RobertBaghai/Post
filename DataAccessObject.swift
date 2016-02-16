//
//  DataAccessObject.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import Foundation
import Parse

class DataAccessObject {
    static let sharedInstance = DataAccessObject()
    var currentUser           = PFUser.currentUser()
    var newError:           NSError?
    var userProfile:        UserProfile?
    var imagePost:          ImagePost?
    var profileName:        String?
    var profileDescription: String?
    var profilePicture:     UIImage?
    var arrayOfUserPosts:   [ImagePost] = []
    
    private init() {
        PFUser.registerSubclass()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "loginError",       object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "loginSuccess",     object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "signupError",      object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "signupSuccess",    object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "getProfileInfo",   object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "retrievedPost",    object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "retrieveUserData", object: nil)
    }
    
    //MARK: Login User with parse
    func loginReturningUser(username:String, password:String) {
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                self.newError = error
                NSNotificationCenter.defaultCenter().postNotificationName("loginError", object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccess", object: nil)
                //retrieve profile info + posts when user logs in successfully
                NSNotificationCenter.defaultCenter().postNotificationName("retrieveUserData", object: nil)
            }
        }
    }
    
    //MARK: Sign Up User With Parse
    func signUpNewUser(username:String, password:String, email:String){
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email    = email
        newUser.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                self.newError = error
                NSNotificationCenter.defaultCenter().postNotificationName("signupError", object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("signupSuccess", object: nil)
                self.insertDefaultUserProfileInfoUponSuccessfulSignup(newUser.objectId!, andUsername: newUser.username!)
                
                //slight issue when user is logged in, logs out and then signs up with new acc.. old profile info
                //still shows if the application is not restarted
                NSNotificationCenter.defaultCenter().postNotificationName("retrieveUserData", object: nil)
                //
            }
        }
    }
    
    //MARK: Input Default New-User Info
    func insertDefaultUserProfileInfoUponSuccessfulSignup (withUserObjectId: String, andUsername:String){
        let defaultAvatar           = UIImage(named: "AvatarPlaceholderBig")
        let imageData: NSData       = UIImagePNGRepresentation(defaultAvatar!)!
        let newFile                 = PFFile(name: "image.png", data: imageData)
        
        let newObject               = PFObject(className: "UserProfile")
        newObject["ProfileName"]    = "FirstName LastName"
        newObject["ProfileAboutMe"] = "User hasn't added a description yet"
        newObject["ProfileAvatar"]  = newFile
        newObject["UserObjectId"]   = withUserObjectId
        newObject["Username"]       = andUsername
        
        newObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("New User. Default Profile Info Saved")
            } else {
                print("There was an error saving user info : \(error?.userInfo), \(error?.localizedDescription)")
            }
        }
    }
    
    //MARK: Update User Profile Info
    func updateCurrentUserProfileInfo(name: String, details: String, avatar: UIImage, currentuserObjectId:String){
        let imageData: NSData = UIImagePNGRepresentation(avatar)!
        let updateFile        = PFFile(name: "newImage.png", data: imageData)
        let query = PFQuery(className: "UserProfile")
        query.whereKey("UserObjectId", equalTo: currentuserObjectId)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            for updatedObject:PFObject in objects! {
                if error != nil {
                    print(error?.userInfo)
                } else {
                    updatedObject["ProfileName"]    = name
                    updatedObject["ProfileAboutMe"] = details
                    updatedObject["ProfileAvatar"]  = updateFile
                    updatedObject.saveInBackgroundWithBlock{
                        (success: Bool, error: NSError?) -> Void in
                        
                        if ( success ) {
                            self.getCurrentUserProfileInfo(self.currentUser!.objectId!)
                        } else {
                            print(error?.userInfo, error?.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Get User Profile Info
    func getCurrentUserProfileInfo(currentuserObjectId:String){
        let query = PFQuery(className: "UserProfile")
        query.whereKey("UserObjectId", equalTo: currentuserObjectId)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            for updatedObject:PFObject in objects! {
                if (error != nil){
                    print(error?.userInfo)
                } else {
                    let profileName:  String       = updatedObject["ProfileName"]    as! String
                    let profileAbout: String       = updatedObject["ProfileAboutMe"] as! String
                    let userObjectId: String       = updatedObject["UserObjectId"]   as! String
                    let objectId:     String       = updatedObject.objectId!
                    let profileAvatar: PFFile      = updatedObject["ProfileAvatar"]  as! PFFile
                    
                    self.userProfile = UserProfile.init(
                        profileName: profileName,
                        description: profileAbout,
                        avatar: profileAvatar,
                        usrId: userObjectId,
                        profileObjId: objectId
                    )
                    NSNotificationCenter.defaultCenter().postNotificationName("getProfileInfo", object: self.userProfile)
                }
            }
        }
    }
    
    //MARK: Save New Post
    func postNewImageForUserId(username: String, userId: String, image: UIImage, imgDescription: String) {
        let imageData: NSData         = UIImagePNGRepresentation(image)!
        let newFile                   = PFFile(name: "imagePosted.png", data: imageData)
        let newObject                 = PFObject(className: "ImagePost")
        newObject["Username"]         = username
        newObject["UserId"]           = userId
        newObject["Image"]            = newFile
        newObject["ImageDescription"] = imgDescription
        newObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if ( success ) {
                print("Image Saved")
                //retrieve image just taken for user, then call retrievedPost notif to reload collectionView..
                //right now it retrieves all images all over again and reloads collectionView
                self.retrieveAllImagesForUserId(self.currentUser!.objectId!)
                //               self.retrieveNewPostedImage(newObject.objectId!)
            } else {
                print(error?.localizedDescription, error?.userInfo)
            }
        }
    }
    
    func retrieveNewPostedImage(imageId: String){
        let query = PFQuery(className: "ImagePost")
        query.orderByDescending("createdAt")
        query.whereKey("objectId", equalTo: imageId)
        query.getObjectInBackgroundWithId(imageId) {
            (object:PFObject?, error: NSError?) -> Void in
            if error != nil {
                let username:    String       = object!["Username"]         as! String
                let userId:      String       = object!["UserId"]           as! String
                let description: String       = object!["ImageDescription"] as! String
                let imageId:     String       = object!.objectId!
                let file:        PFFile       = object!["Image"]            as! PFFile
                
                self.imagePost = ImagePost.init(
                    image: file,
                    userId: userId,
                    imageId: imageId,
                    description: description,
                    username: username)
                self.arrayOfUserPosts.append(self.imagePost!)
                //reload collection view
            }
        }
    }
    
    //MARK: Retrieve Posts for UserId
    func retrieveAllImagesForUserId(userId:String){
        self.arrayOfUserPosts.removeAll()
        let query = PFQuery(className: "ImagePost")
        query.whereKey("UserId", equalTo: userId)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (object:[PFObject]?, error:NSError?) -> Void in
            
            if ( error != nil ){
                print(error?.localizedDescription, error?.userInfo)
            } else {
                
                for temp: PFObject in object! {
                    let username:    String       = temp["Username"]         as! String
                    let userId:      String       = temp["UserId"]           as! String
                    let description: String       = temp["ImageDescription"] as! String
                    let imageId:     String       = temp.objectId!
                    let file:        PFFile       = temp["Image"]            as! PFFile
                    
                    self.imagePost = ImagePost.init(
                        image: file,
                        userId: userId,
                        imageId: imageId,
                        description: description,
                        username: username
                    )
                    self.arrayOfUserPosts.append(self.imagePost!)
                }
                NSNotificationCenter.defaultCenter().postNotificationName("retrievedPost", object: nil)
            }
        }
    }
    
    //MARK: Log out Current User
    func logoutUser(){
        // Clear all caches, then log out user
        PFQuery.clearAllCachedResults()
        PFUser.logOut()
    }
    
    //MARK: Get Current User
    func getCurrentUser(){
        self.currentUser = PFUser.currentUser()
    }
    
    //MARK: Notification Center
    @objc func updateNotificaitonSent(notification: NSNotification) {
        print("\(notification.name) notificaiton sent")
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}
