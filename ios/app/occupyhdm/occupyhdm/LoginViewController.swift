//
//  LoginViewController.swift
//  occupyhdm
//
//  Created by Fabian Kugler on 15.03.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
    @IBOutlet weak var usernameTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func startGame(sender: AnyObject) {
        if usernameTextfield.text != ""
        {
            NSUserDefaults.standardUserDefaults().setObject(usernameTextfield.text, forKey: "username")
            
            self.performSegueWithIdentifier("showLoginToMain", sender: self)
        }
    }
}