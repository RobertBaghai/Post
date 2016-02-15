//
//  InboxViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {
    let dataAccess = DataAccessObject.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataAccess.getCurrentUser()
        let currentUser = dataAccess.currentUser
        if currentUser != nil {
            print("Current User: \(currentUser!.username!)")
        } else {
            performSegueWithIdentifier("showLoginScreen", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    } 
    
    @IBAction func logout(sender: AnyObject) {
        dataAccess.logoutUser()
        performSegueWithIdentifier("showLoginScreen", sender: self)
        print("Log Out Successful")
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showLoginScreen") {
            if let loginView: LogInViewController = segue.destinationViewController as? LogInViewController {
                loginView.navigationItem.hidesBackButton = true
                loginView.hidesBottomBarWhenPushed = true
            }
        }
    }
}