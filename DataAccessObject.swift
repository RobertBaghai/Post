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
    var currentUser = PFUser.currentUser()
    var newError: NSError?
    var userProfile: UserProfile?
    var imagePost: ImagePost?
    var profileName: String?
    var profileDescription: String?
    var profilePicture: UIImage?
    var arrayOfUserPosts: [ImagePost] = []
    
    private init() {
        PFUser.registerSubclass()
    }
    
    //MARK: Login User with parse
    func loginReturningUser(username:String, password:String) {
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                self.newError = error
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "loginError", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("loginError", object: self)
            } else {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "loginSuccess", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccess", object: self)
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
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "signupError", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("signupError", object: self)
            } else {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "signupSuccess", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("signupSuccess", object: self)
                self.insertDefaultUserProfileInfoUponSuccessfulSignup(newUser.objectId!, andUsername: newUser.username!)
            }
        }
    }
    
    //MARK: Default User Info
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
    func updateExistingUserProfileInfo(name: String, details: String, avatar: UIImage, forUserProfileObjectId:String){
        let imageData: NSData = UIImagePNGRepresentation(avatar)!
        let updateFile        = PFFile(name: "newImage.png", data: imageData)
        
        let query = PFQuery(className: "UserProfile")
        query.getObjectInBackgroundWithId("\(forUserProfileObjectId)"){
            (updatedObject:PFObject?, error: NSError?) -> Void in
            if (error != nil){
                print(error?.userInfo)
            } else {
                updatedObject!["ProfileName"]    = name
                updatedObject!["ProfileAboutMe"] = details
                updatedObject!["ProfileAvatar"]  = updateFile
                updatedObject?.saveInBackground()
            }
        }
    }
    
    func getObjectIdFromUserProfileParseClassForUser(currentUserId: String,name: String, details: String, avatar: UIImage) {
        let query = PFQuery(className: "UserProfile")
        query.whereKey("UserObjectId", equalTo: currentUserId)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?,error: NSError?) -> Void in
            for tempParseObj:PFObject in objects! {
                if error != nil {
                    print(error?.userInfo)
                } else {
                    self.updateExistingUserProfileInfo(name, details: details, avatar: avatar, forUserProfileObjectId: tempParseObj.objectId!)
                }
            }
        }
    }
    
    //MARK: Get User Profile Info
    func getExistingUserProfileInfo(forUserProfileObjectId:String){
        let query = PFQuery(className: "UserProfile")
        query.getObjectInBackgroundWithId("\(forUserProfileObjectId)"){
            (updatedObject:PFObject?, error: NSError?) -> Void in
            if (error != nil){
                print(error?.userInfo)
            } else {
                self.profileName        = updatedObject!["ProfileName"] as? String
                self.profileDescription = updatedObject!["ProfileAboutMe"] as? String
                self.profilePicture     = updatedObject!["ProfileAvatar"] as? UIImage
            }
        }
    }
    
    func getObjectIdToDisplayUserInfo(currentUserId: String) {
        let query = PFQuery(className: "UserProfile")
        query.whereKey("UserObjectId", equalTo: currentUserId)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?,error: NSError?) -> Void in
            for tempParseObj:PFObject in objects! {
                if error != nil {
                    print(error?.userInfo)
                } else {
                    let profileName: String       = tempParseObj["ProfileName"]    as! String
                    let profileAbout: String      = tempParseObj["ProfileAboutMe"] as! String
                    let tempprofileAvatar: PFFile = tempParseObj["ProfileAvatar"]  as! PFFile
                    let profileAvatar:UIImage     =  try! UIImage(data: tempprofileAvatar.getData())!
                    let userObjectId: String      = tempParseObj["UserObjectId"]   as! String
                    let objectId: String          = tempParseObj.objectId!
                    
                    self.userProfile = UserProfile.init(
                        profileName: profileName,
                        description: profileAbout,
                        avatar: profileAvatar,
                        usrId: userObjectId,
                        profileObjId: objectId
                    )
                    self.getExistingUserProfileInfo(tempParseObj.objectId!)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "getProfileInfo", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("getProfileInfo", object: self)
                }
            }
        }
    }
    
    //MARK: Save/ Retrieve New Image Post
    func postImageForUserId(username: String, userId: String, image: UIImage, imgDescription: String) {
        let newObject = PFObject(className: "ImagePost")
        let imageData: NSData = UIImagePNGRepresentation(image)!
        let newFile = PFFile(name: "imagePosted.png", data: imageData)
        newObject["Username"] = username
        newObject["UserId"] = userId
        newObject["Image"] = newFile
        newObject["ImageDescription"] = imgDescription
        newObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if ( success) {
                print(newObject.objectId)
                print("Image Saved")
                self.retrieveParseImagesForUser(userId, withImageId: newObject.objectId!)
                
            } else {
                print(error?.localizedDescription, error?.userInfo)
            }
        }
    }
    
    func retrieveParseImagesForUser(userId:String, withImageId: String){
        let query = PFQuery(className: "ImagePost")
        query.whereKey("UserId", equalTo: userId)
        query.findObjectsInBackgroundWithBlock {
            (object:[PFObject]?, error:NSError?) -> Void in
            
            for temp: PFObject in object! {
                let username = temp["Username"] as? String
                let userId   = temp["UserId"] as? String
                let description = temp["ImageDescription"] as? String
                
                let file:PFFile     = temp["Image"] as! PFFile
                let retrievedImage:UIImage = try! UIImage(data: file.getData())!
                
                self.imagePost = ImagePost.init(image: retrievedImage, userId: userId!, imageId: withImageId, description: description!, username: username!)
                self.arrayOfUserPosts.append(self.imagePost!)
            }
            print("\(self.arrayOfUserPosts)")
        }
    }
    
    //MARK: test
    func retrieveAllImages(userId:String){
        let query = PFQuery(className: "ImagePost")
        query.whereKey("UserId", equalTo: userId)
        query.findObjectsInBackgroundWithBlock {
            (object:[PFObject]?, error:NSError?) -> Void in
            
            for temp: PFObject in object! {
                let username = temp["Username"] as? String
                let userId   = temp["UserId"] as? String
                let description = temp["ImageDescription"] as? String
                
                let file:PFFile     = temp["Image"] as! PFFile
                let retrievedImage:UIImage = try! UIImage(data: file.getData())!
                let imageId: String = temp.objectId!
                
                self.imagePost = ImagePost.init(image: retrievedImage, userId: userId!, imageId: imageId, description: description!, username: username!)
                self.arrayOfUserPosts.append(self.imagePost!)
            }
            print("\(self.arrayOfUserPosts)")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificaitonSent:", name: "post", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("post", object: self)
        }
    }
    
    //MARK: Log out Current User
    func logoutUser(){
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
