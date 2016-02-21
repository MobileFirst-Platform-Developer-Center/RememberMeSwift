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
    var remainingAttempts: Int
    override init(){
        self.remainingAttempts = -1
        super.init(securityCheck: "UserLogin")
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: loginNotificationKey, object: nil)
    }
    
    func login(notification:NSNotification){
        var username: String!
        var password: String!
        var rememberMe: String!
        let userInfo = notification.userInfo as! Dictionary<String, String!>
        username = userInfo["username"]
        password = userInfo["password"]
        rememberMe = userInfo["rememberMe"]
        //NSLog("username: " + username + " Password: " + password + " rememberMe: " + rememberMe)
        WLAuthorizationManager.sharedInstance().login("UserLogin", withCredentials: ["username": username, "password": password, "rememberMe": rememberMe]) { (error) -> Void in
            NSLog("login")
            if(error != nil){
                NSLog("Login failed")
            }
            else{
                NSLog("Login success")
            }
        }
    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        NSLog("handleChallenge")
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        NSLog("handleSuccess")
        var displayName: String!
        displayName = success["user"]!["displayName"]! as! String
        NSLog("displayName: " + displayName)
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        NSLog("handleFailure")
    }

}
