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

class ProtectedViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var errMsg: String!
    var remainingAttempts: Int!
    
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var displayBalanceLabel: UILabel!
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginRequired:", name: LoginRequiredNotificationKey, object: nil)
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if(defaults.stringForKey("displayName") != nil){
            self.helloUserLabel.text = "Hello, " + defaults.stringForKey("displayName")!
        }
        self.navigationItem.hidesBackButton = true;
    }
    
    // getBalanceClicked
    @IBAction func getBalanceClicked(sender: UIButton) {
        let url = NSURL(string: "/adapters/ResourceAdapter/balance");
        let request = WLResourceRequest(URL: url, method: WLHttpMethodGet);
        request.sendWithCompletionHandler{ (WLResponse response, NSError error) -> Void in
            if(error != nil){
                NSLog("Failed to get balance. error: " + String(error))
                self.displayBalanceLabel.text = "Failed to get balance...";
            }
            else if(response != nil){
                self.displayBalanceLabel.text = "Balance: " + response.responseText;
            }
        }
    }
    
    // logoutClicked
    @IBAction func logoutClicked(sender: UIButton) {
        //navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotificationName(LogoutNotificationKey, object: nil)
        self.performSegueWithIdentifier("LogoutSegue", sender: nil)
    }
    
    // loginRequired
    func loginRequired(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject!>
        self.errMsg =  userInfo["errorMsg"] as! String
        self.remainingAttempts = userInfo["remainingAttempts"] as! Int
        
        self.performSegueWithIdentifier("TimedOutSegue", sender: nil)
    }
        
    // prepareForSegue (for TimedOutSegue)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "TimedOutSegue") {
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
