//
//  SimpSignInVC.swift
//  MorseChat
//
//  Created by William Wold on 7/13/16.
//  Copyright © 2016 Widap. All rights reserved.
//

import UIKit

class SimpSignInVC : UIViewController {
	
	@IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		blurView.hidden=true;
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		
	}
	
	func loginSuccess() {
		
		firebaseHelper.getFrienArray(
			{ (usrAry) in
				friends = usrAry
				friendsDownloaded = true
				self.performSegueWithIdentifier("logInSegue", sender: self)
			}
		)
	}
	
	@IBAction func signInBtn0(sender: AnyObject) {
		
		blurView.hidden=false;
		
		firebaseHelper.signInWithEmail("widap@mailinator.com", password: "password", successCallback: loginSuccess, failCallback: {})
	}
	
	@IBAction func SignInBtn1(sender: AnyObject) {
		
		blurView.hidden=false;
		
		firebaseHelper.signInWithEmail("widap0@mailinator.com", password: "password", successCallback: loginSuccess, failCallback: {})
	}
	
}