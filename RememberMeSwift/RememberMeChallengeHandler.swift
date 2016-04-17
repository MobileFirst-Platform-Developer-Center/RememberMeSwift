/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import IBMMobileFirstPlatformFoundation

class RememberMeChallengeHandler: WLChallengeHandler {
    
    var isChallenged: Bool
    let defaults = NSUserDefaults.standardUserDefaults()
    let challengeHandlerName = "RememberMeChallengeHandler"
    
    override init(){
        self.isChallenged = false
        super.init(securityCheck: "UserLogin")
        WLClient.sharedInstance().registerChallengeHandler(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(login(_:)), name: LoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: LogoutNotificationKey, object: nil)
    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        if (defaults.stringForKey("displayName") != nil){
            defaults.removeObjectForKey("displayName")
        }
        self.isChallenged = true
        var errMsg: String!
        
        if(challenge["errorMsg"] is NSNull){
            errMsg = ""
        } else {
            errMsg = challenge["errorMsg"] as! String
        }
        let remainingAttempts = challenge["remainingAttempts"]
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginRequiredNotificationKey, object: nil, userInfo: ["errorMsg":errMsg!, "remainingAttempts":remainingAttempts!])
        
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        self.isChallenged = false
        self.defaults.setObject(success["user"]!["displayName"]! as! String, forKey: "displayName")
        NSNotificationCenter.defaultCenter().postNotificationName(LoginSuccessNotificationKey, object: nil)
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleFailure - \(failure)")
        if (defaults.stringForKey("displayName") != nil){
            defaults.removeObjectForKey("displayName")
        }
        self.isChallenged = false
        if let _ = failure["failure"] as? String {
            NSNotificationCenter.defaultCenter().postNotificationName(LoginFailureNotificationKey, object: nil, userInfo: ["errorMsg":failure["failure"]!])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(LoginFailureNotificationKey, object: nil, userInfo: ["errorMsg":"Unknown error"])
        }
    }
    
    // (Triggered by Login Notification)
    func login(notification:NSNotification){
        print("\(self.challengeHandlerName): login")
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let username = userInfo["username"] as! String
        let password = userInfo["password"] as! String
        let rememberMe = userInfo["rememberMe"] as! Bool
        
        // If challenged use submitChallengeAnswer API, else use login API
        if(!self.isChallenged){
            WLAuthorizationManager.sharedInstance().login(self.securityCheck, withCredentials: ["username": username, "password": password, "rememberMe": rememberMe]) { (error) -> Void in
                if(error != nil){
                    print("Login failed \(String(error))")
                } else {
                    print("\(self.challengeHandlerName): preemptiveLogin success")
                    NSNotificationCenter.defaultCenter().postNotificationName(ObtainAccessTokenSuccessKey, object: nil, userInfo: nil)
                }
            }
        }
        else{
            print("submitChallengeAnswer")
            self.submitChallengeAnswer(["username": username, "password": password, "rememberMe": rememberMe])
        }
    }
    
    // (Triggered by Logout Notification)
    func logout(){
        print("\(self.challengeHandlerName): logout")
        self.defaults.removeObjectForKey("displayName")
        WLAuthorizationManager.sharedInstance().logout(self.securityCheck){
            (error) -> Void in
            if(error != nil){
                print("Logout failed \(String(error))")
            }
            print("\(self.challengeHandlerName): logout success")
            self.isChallenged = false
        }
        
    }
}
