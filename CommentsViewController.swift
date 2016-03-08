//
//  CommentsViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/16/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    var imagePost:          ImagePost?
    var userProfile:        UserProfile?
    let dataAccess  = DataAccessObject.sharedInstance
    var imageId: String?
    var userId: String?
    var username: String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView", name: "retrieveComments", object: nil)

        setInitalValues()
        self.tableView.dataSource = self
        self.tableView.delegate   = self        
        dataAccess.retrieveCommentsForImageId(id: self.imagePost!.imageId!)
    }
    
    func reloadTableView(){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setInitalValues(){
        self.commentTextField.delegate = self
        let imageUrl:NSURL? = NSURL(string: "\(self.imagePost!.postedImage!.url!)")
        if let url = imageUrl {
            self.userImage.sd_setImageWithURL(url)
        }
    }
    
    func setProperties(){
        self.imageId  = self.imagePost!.imageId!
        self.userId   = self.imagePost!.userId!
        self.username = self.imagePost!.username!
    }
    
    @IBAction func addCommentButton(sender: AnyObject) {
        setProperties()
        dataAccess.postCommentToImageId(id: imageId!, userId: userId!, username: username!, comment: self.commentTextField!.text!)
        self.commentTextField.text = ""
//        dataAccess.retrieveCommentsForImageId(id: self.imagePost!.imageId!)
    }
    
    
    //MARK: TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAccess.arrayOfComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let imagePostDetail: ImagePostDetail = dataAccess.arrayOfComments[indexPath.row]
        cell.textLabel?.text                 = imagePostDetail.comment!
        cell.detailTextLabel?.text           = "Posted By: \(imagePostDetail.username!)"
        dataAccess.getUserAvatarForTableViewComment(imagePostDetail.userId!, cell: cell)
        
        return cell
    }
    
    
    
    //MARK: TableView Delegate
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
