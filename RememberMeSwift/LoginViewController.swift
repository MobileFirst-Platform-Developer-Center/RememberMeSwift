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

class LoginViewController: UIViewController {
    
    var errorViaSegue: String!
    var remainingAttemptsViaSegue: Int!
    var displayName: String!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var remainingAttempts: UILabel!
    @IBOutlet weak var error: UILabel!
    
    // viewWillAppear
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccess", name: LoginSuccessNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanFieldsAndLabels", name: LoginFailureNotificationKey, object: nil)
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
    }
    
    // login
    @IBAction func login(sender: UIButton) {
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(LoginNotificationKey, object: nil, userInfo: ["username": username.text!, "password": password.text!, "rememberMe": rememberMe.on])
        }
    }
    
    // updateLabels (triggered by LoginRequired notification)
    func updateLabels(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let errMsg = userInfo["errorMsg"] as! String
        let remainingAttempts = userInfo["remainingAttempts"] as! Int
        self.error.text = errMsg
        self.remainingAttempts.text = "Remaining Attempts: " + String(remainingAttempts)
    }
    
    // loginSuccess (triggered by LoginSuccess notification)
    func loginSuccess(){
        self.performSegueWithIdentifier("gotoBalancePageSegue", sender: nil)
    }
    
    // cleanFieldsAndLabels (triggered by LoginFailure notification)
    func cleanFieldsAndLabels(){
        self.username.text = ""
        self.password.text = ""
        self.remainingAttempts.text = ""
        self.error.text = ""
    }
    
    // viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
