//
//  ProtectedViewController.swift
//  RememberMeSwift
//
//  Created by Shmulik Bardosh on 18/02/2016.
//  Copyright © 2016 Shmulik Bardosh. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

let logoutButtonClickedNotificationKey = "com.sample.RememberMeSwift.logoutButtonClickedNotificationKey"

class ProtectedViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var displayBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        NSLog("ProtectedViewController->viewDidLoad")
        super.viewDidLoad()
        if(defaults.stringForKey("displayName") != nil){
            self.helloUserLabel.text = "Hello, " + defaults.stringForKey("displayName")!
        }
        self.navigationItem.hidesBackButton = true;
    }

    @IBAction func getBalanceClicked(sender: UIButton) {
        NSLog("getBalanceClicked")
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
    
    
    @IBAction func logoutClicked(sender: UIButton) {
        NSLog("logoutClicked")
        navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotificationName(LogoutNotificationKey, object: nil)
    }
    
}
