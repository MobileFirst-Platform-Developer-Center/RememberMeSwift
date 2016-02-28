//
//  rememberMeChallengeHandler.swift
//  RememberMeSwift
//
//  Created by Shmulik Bardosh on 18/02/2016.
//  Copyright © 2016 Shmulik Bardosh. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

class RememberMeChallengeHandler: WLChallengeHandler {
    var isChallenged: Bool
    let defaults = NSUserDefaults.standardUserDefaults()
    override init(){
        self.isChallenged = false
        super.init(securityCheck: "UserLogin")
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: LoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: LogoutNotificationKey, object: nil)
    }
    
    // login
    func login(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let username = userInfo["username"] as! String
        let password = userInfo["password"] as! String
        let rememberMe = userInfo["rememberMe"] as! Bool
        if(!isChallenged){
            WLAuthorizationManager.sharedInstance().login("UserLogin", withCredentials: ["username": username, "password": password, "rememberMe": rememberMe]) { (error) -> Void in
                NSLog("login")
                if(error != nil){
                    NSLog("Login failed" + String(error))
                }
                else{
                    NSLog("Login success")
                }
            }
        }
        else{
            self.submitChallengeAnswer(["username": username, "password": password, "rememberMe": rememberMe])
        }
    }
    
    // logout
    func logout(){
        WLAuthorizationManager.sharedInstance().logout("UserLogin"){
            (error) -> Void in
            if(error != nil){
                NSLog("Logout failed")
            }
            else{
                NSLog("Logged out!")
                
            }
        }
        self.isChallenged = false
    }
    
    // handleChallenge
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        NSLog("handleChallenge")
        NSLog("challenge: " + String(challenge))
        isChallenged = true
        self.defaults.removeObjectForKey("displayName")
        var errMsg: String!
        
        if(challenge["errorMsg"] is NSNull){
            errMsg = ""
        }
        else{
            errMsg = challenge["errorMsg"] as! String
        }
        let remainingAttempts = challenge["remainingAttempts"]
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginRequiredNotificationKey, object: nil, userInfo: ["errorMsg":errMsg!, "remainingAttempts":remainingAttempts!])
        
    }
    
    // handleSuccess
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        NSLog("handleSuccess")
        isChallenged = false
        self.defaults.setObject(success["user"]!["displayName"]! as! String, forKey: "displayName")
        NSNotificationCenter.defaultCenter().postNotificationName(LoginSuccessNotificationKey, object: nil)
    }
    
    // handleFailure
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        NSLog("handleFailure")
        isChallenged = false
        if let errMsg = failure["failure"] as? String {
            showError(errMsg)
        }
        else{
            showError("Unknown error")
        }
        NSNotificationCenter.defaultCenter().postNotificationName(LoginFailureNotificationKey, object: nil)
    }
    
    // showError
    func showError(errorMsg: String){
        let alert = UIAlertController(title: "Error",
            message: errorMsg,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue()) {
            let topController = UIApplication.sharedApplication().keyWindow!.rootViewController! as UIViewController
            topController.presentViewController(alert,
                animated: true,
                completion: nil)
        }
    }

}
