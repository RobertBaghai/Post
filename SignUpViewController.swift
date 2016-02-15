//
//  SignUpViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    let dataAccess = DataAccessObject.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
        emailField.delegate    = self
        addSignupObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Handle User Sign up
    @IBAction func signup(sender: AnyObject) {
        
        let newUser     = self.usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let newPassword = self.passwordField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let newEmail    =    self.emailField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if( newUser?.characters.count == 0 || newPassword?.characters.count == 0 || newEmail?.characters.count == 0 ){
            let alertController = UIAlertController.init(title: "Oops!", message: "Make sure all fields are filled in!", preferredStyle: .ActionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dataAccess.signUpNewUser(newUser!, password: newPassword!, email: newEmail!)
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: Notification Center
    func addSignupObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "signupSuccessNotificationRecieved", name: "signupSuccess", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "signupErrorNotificationRecieved", name: "signupError", object: nil)
    }
    
    func signupSuccessNotificationRecieved(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func signupErrorNotificationRecieved(){
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
