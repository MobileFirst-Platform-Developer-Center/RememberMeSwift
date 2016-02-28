//
//  ViewController.swift
//  RememberMeSwift
//
//  Created by Shmulik Bardosh on 18/02/2016.
//  Copyright © 2016 Shmulik Bardosh. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

//let LoginRequiredNotificationKey = "com.sample.RememberMeSwift.LoginRequiredNotificationKey"
//let LoginSuccessNotificationKey = "com.sample.RememberMeSwift.LoginSuccessNotificationKey"

class HomeViewController: UIViewController {
    var errMsg: String!
    var remainingAttempts: Int!
    var displayName: String!
    
    override func viewWillAppear(animated: Bool) {
        NSLog("HomeViewController->viewWillAppear")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayLoginScreen:", name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayBalanceScreen", name: LoginSuccessNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayLoginScreen:", name: LogoutNotificationKey, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("HomeViewController->viewDidLoad")
        WLAuthorizationManager.sharedInstance().obtainAccessTokenForScope("UserLogin") { (token, error) -> Void in
            NSLog("obtainAccessToken")
            if(error != nil){
                NSLog("obtainAccessToken failed! " + String(error))
            }
            else{
                NSLog("obtainAccessToken success")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        NSLog("HomeViewController->prepareForSegue")
        if (segue.identifier == "ShowLoginScreenSegue") {
            if let destination = segue.destinationViewController as? LoginViewController{
                destination.errorViaSegue = self.errMsg
                destination.remainingAttemptsViaSegue = self.remainingAttempts
            }
        }
    }
    
    func displayLoginScreen(notification:NSNotification){
        NSLog("displayLoginScreen")
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        self.errMsg =  userInfo["errorMsg"] as! String
        self.remainingAttempts = userInfo["remainingAttempts"] as! Int
        
        self.performSegueWithIdentifier("ShowLoginScreenSegue", sender: nil)
    }
    
    func displayBalanceScreen(){
        NSLog("displayBalanceScreen")
        self.performSegueWithIdentifier("fromHomeToBalanceSegue", sender: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSLog("HomeViewController->viewDidDisappear")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

