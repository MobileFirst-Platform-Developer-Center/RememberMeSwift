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
    
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var displayBalanceLabel: UILabel!
    @IBOutlet weak var getBalanceBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WLAuthorizationManager.sharedInstance().obtainAccessTokenForScope("UserLogin") { (token, error) -> Void in
            if(error != nil){
                print("obtainAccessToken failed! \(String(error))")
            }
            else{
                print("obtainAccessToken success")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShowLoginScreen(_:)), name: LoginRequiredNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshUI), name: LoginSuccessNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShowLoginScreen(_:)), name: LoginFailureNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShowLoginScreen(_:)), name: logoutSuccessNotificationKey, object: nil)
        refreshUI()
    }
    
    func refreshUI(){
        print("refreshUI")
        if let displayName = defaults.stringForKey("displayName"){
            self.getBalanceBtn.hidden = false
            self.logoutBtn.hidden = false
            self.helloUserLabel.hidden = false
            self.helloUserLabel.text = "Hello, " + displayName
            self.displayBalanceLabel.text = ""
        }
    }
    
    @IBAction func getBalanceClicked(sender: UIButton) {
        let url = NSURL(string: "/adapters/ResourceAdapter/balance");
        let request = WLResourceRequest(URL: url, method: WLHttpMethodGet);
        request.sendWithCompletionHandler{ (response, error) -> Void in
            if(error != nil){
                NSLog("Failed to get balance. error: " + String(error))
                self.displayBalanceLabel.text = "Failed to get balance...";
            }
            else if(response != nil){
                self.displayBalanceLabel.text = "Balance: " + response.responseText;
            }
        }
    }
    
    @IBAction func logoutClicked(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(LogoutNotificationKey, object: nil)
    }
    
    func ShowLoginScreen(notification:NSNotification){
        print("ShowLoginScreen")
        self.performSegueWithIdentifier("ShowLoginScreen", sender: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
