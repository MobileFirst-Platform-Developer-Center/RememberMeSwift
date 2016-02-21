//
//  LoginViewController.swift
//  RememberMeSwift
//
//  Created by Shmulik Bardosh on 18/02/2016.
//  Copyright © 2016 Shmulik Bardosh. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

let loginNotificationKey = "com.sample.RememberMeSwift.loginNotificationKey"
let showBalanceNotificationKey = "com.sample.RememberMeSwift.showBalanceNotificationKey"

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var remainingAttempts: UILabel!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rememberMe.on = false
    }
    
    @IBAction func login(sender: UIButton) {
        var strRememberMe: String!
        if(rememberMe.on){
            strRememberMe = "true"
        }
        else{
            strRememberMe = "false"
        }
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(loginNotificationKey, object: nil, userInfo: ["username": username.text!, "password": password.text!, "rememberMe": strRememberMe])
        }
    }
}
