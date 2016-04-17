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
        
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var remainingAttempts: UILabel!
    @IBOutlet weak var error: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.username.text = ""
        self.password.text = ""
        rememberMe.on = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateLabels(_:)), name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccess), name: LoginSuccessNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailure(_:)), name: LoginFailureNotificationKey, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(sender: UIButton) {
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(LoginNotificationKey, object: nil, userInfo: ["username": username.text!, "password": password.text!, "rememberMe": rememberMe.on])
        } else {
            self.error.text = "Username and password are required"
        }
    }
    
    //(triggered by LoginRequired notification)
    func updateLabels(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let errMsg = userInfo["errorMsg"] as! String
        let remainingAttempts = userInfo["remainingAttempts"] as! Int
        self.error.text = errMsg
        self.remainingAttempts.text = "Remaining Attempts: " + String(remainingAttempts)
    }
    
    //(triggered by LoginSuccess notification)
    func loginSuccess(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //(triggered by LoginFailure notification)
    func loginFailure(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        let errMsg = userInfo["errorMsg"] as! String
        
        let alert = UIAlertController(title: "Error",
            message: errMsg,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        self.username.text = ""
        self.password.text = ""
        self.remainingAttempts.text = ""
        self.error.text = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        print("LoginViewController: viewDidDisappear")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
