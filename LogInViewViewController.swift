//
//  LogInViewViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let dataAccess = DataAccessObject.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField!.delegate = self
        passwordField!.delegate = self
        addLoginObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    //MARK: Handle User Login
    @IBAction func login(sender: AnyObject) {
        
        let username = self.usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = self.passwordField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if( username?.characters.count == 0 || password?.characters.count == 0 ){
            let alertController = UIAlertController.init(title: "Oops!", message: "Make sure both fields are filled in!", preferredStyle: .ActionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            dataAccess.loginReturningUser(username!, password: password!)
            print("\(username!) signed in.")
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    //MARK: Notification Center
    func addLoginObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccessNotificationRecieved", name: "loginSuccess", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginErrorNotificationRecieved", name: "loginError", object: nil)
    }
    
    func loginSuccessNotificationRecieved(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func loginErrorNotificationRecieved(){
        let errorString = dataAccess.newError!.userInfo["error"] as? NSString
        print(errorString)
        let alertController = UIAlertController.init(title: "Oops!", message: "\(errorString!)", preferredStyle: .ActionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}