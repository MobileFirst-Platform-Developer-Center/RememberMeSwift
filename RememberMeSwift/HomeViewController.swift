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

class HomeViewController: UIViewController {
    
    var errMsg: String!
    var remainingAttempts: Int!
    var displayName: String!
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginRequired(_:)), name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccess), name: LoginSuccessNotificationKey, object: nil)
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

