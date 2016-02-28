//
//  ViewController.swift
//  RememberMeSwift
//

import UIKit
import IBMMobileFirstPlatformFoundation

class HomeViewController: UIViewController {
    
    var errMsg: String!
    var remainingAttempts: Int!
    var displayName: String!
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginRequired:", name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccess", name: LoginSuccessNotificationKey, object: nil)
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // obtainAccessToken
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
    
    // loginRequired  (Triggered by LoginRequired notification)
    func loginRequired(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        self.errMsg =  userInfo["errorMsg"] as! String
        self.remainingAttempts = userInfo["remainingAttempts"] as! Int
        
        self.performSegueWithIdentifier("ShowLoginScreenSegue", sender: nil)
    }
    
    // loginSuccess  (Triggered by LoginSuccess notification)
    func loginSuccess(){
        self.performSegueWithIdentifier("fromHomeToBalanceSegue", sender: nil)
    }
    
    // prepareForSegue (for ShowLoginScreenSegue)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "ShowLoginScreenSegue") {
            if let destination = segue.destinationViewController as? LoginViewController{
                destination.errorViaSegue = self.errMsg
                destination.remainingAttemptsViaSegue = self.remainingAttempts
            }
        }
    }
    
    // viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

