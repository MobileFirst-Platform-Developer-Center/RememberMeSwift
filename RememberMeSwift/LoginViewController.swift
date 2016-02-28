//
//  LoginViewController.swift
//  RememberMeSwift
//
//  Created by Shmulik Bardosh on 18/02/2016.
//  Copyright © 2016 Shmulik Bardosh. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

class LoginViewController: UIViewController {
    var errorViaSegue: String!
    var remainingAttemptsViaSegue: Int!
    var displayName: String!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var remainingAttempts: UILabel!
    @IBOutlet weak var error: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        self.username.text = ""
        self.password.text = ""
        rememberMe.on = false
        if(self.remainingAttemptsViaSegue != nil) {
            self.remainingAttempts.text = "Remaining Attempts: " + String(self.remainingAttemptsViaSegue)
        }
        if(self.errorViaSegue != nil) {
            self.error.text = self.errorViaSegue
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLabels:", name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoBalancePage", name: LoginSuccessNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanFieldsAndLabels", name: LoginFailureNotificationKey, object: nil)
    }
    
    override func viewDidLoad() {
        NSLog("LoginViewController->viewDidLoad")
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
    }
    
    @IBAction func login(sender: UIButton) {
        NSLog("LoginViewController->login")
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(LoginNotificationKey, object: nil, userInfo: ["username": username.text!, "password": password.text!, "rememberMe": rememberMe.on])
        }
    }
    
    func updateLabels(notification:NSNotification){
        NSLog("LoginViewController->updateLabels")
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let errMsg = userInfo["errorMsg"] as! String
        let remainingAttempts = userInfo["remainingAttempts"] as! Int
        self.error.text = errMsg
        self.remainingAttempts.text = "Remaining Attempts: " + String(remainingAttempts)
    }
    
    func gotoBalancePage(){
        NSLog("LoginViewController->gotoBalancePage")
        self.performSegueWithIdentifier("gotoBalancePageSegue", sender: nil)
    }
    
    func cleanFieldsAndLabels(){
        self.username.text = ""
        self.password.text = ""
        self.remainingAttempts.text = ""
        self.error.text = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSLog("LoginViewController->viewDidDisappear")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
