//
//  EditProfileVC.swift
//  MorseChat
//
//  Created by William Wold on 7/21/16.
//  Copyright © 2016 Widap. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
	
	
	@IBOutlet weak var displayNameBox: UITextField!
	@IBOutlet weak var usernameBox: UITextField!
	
	
	@IBOutlet weak var saveBtn: UIButton!
	//@IBOutlet weak var goodLabel: UILabel!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	@IBOutlet weak var savingSpinnerView: UIView!
	
	
	var usernameBeingChecked = false
	var usernameAvailable = true
	var savingMe = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		errorLabel.numberOfLines = 0
		errorLabel.lineBreakMode = .ByWordWrapping
		errorLabel.adjustsFontSizeToFitWidth=true
		
		savingMe = false
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		firebaseHelper.loginChangedCallback = returnToWelcome
		
		firebaseHelper.initialAccountSetupDone = true
		
		savingSpinnerView.hidden = true
		displayNameBox.text = me.displayName
		usernameBox.text = me.username
		showGood()
	}
	
	override func viewDidAppear(animated: Bool) {
		if !firebaseHelper.isLoggedIn() {
			returnToWelcome()
		}
	}
	
	func showGood() {
		
		saveBtn.hidden = false
		spinner.hidden = true
		errorLabel.hidden = true
	}
	
	func showSpinner() {
		
		//saveBtn.hidden = true
		spinner.hidden = false
		//errorLabel.hidden = true
	}
	
	func showError(msg: String) {
		
		errorLabel.text = msg
		
		saveBtn.hidden = true
		spinner.hidden = true
		errorLabel.hidden = false
	}
	
	@IBAction func displayNameUpdated(sender: AnyObject) {
		inputUpdated()
	}
	
	@IBAction func usernameUpdated(sender: AnyObject) {
		usernameBeingChecked = true
		inputUpdated()
		firebaseHelper.checkIfUsernameAvailable(usernameBox.text ?? "", ignoreMe: true,
			callback: { (available) in
				if self.viewIfLoaded != nil {
					self.usernameBeingChecked = false
					self.usernameAvailable = available
					self.inputUpdated()
				}
			}
		)
	}
	
	func inputUpdated() {
		
		if (displayNameBox.text == nil || displayNameBox.text!.isEmpty) {
			showError("Display name required")
			return;
		}
		
		let err = User.checkUsername(usernameBox.text ?? "")
		
		if let err = err {
			showError(err)
			return;
		}
		
		if usernameBeingChecked {
			showSpinner()
			return;
		}
		
		if !usernameAvailable {
			showError("Username already taken")
			return;
		}
		
		showGood()
	}
	
	@IBAction func saveButtonPressed(sender: AnyObject) {
		
		if !savingMe && !usernameBeingChecked {
			
			savingSpinnerView.hidden = false
			
			let newMe = me.copy()
			
			newMe.displayName = displayNameBox.text ?? "display name error"
			newMe.username = usernameBox.text ?? "usename error"
			
			savingMe = true
			
			firebaseHelper.uploadMe(newMe,
				success: {
					
					self.savingMe = false
					self.exit()
				},
				fail: { (errMsg) in
					self.savingMe = false
					self.savingSpinnerView.hidden = true
					self.showError(errMsg)
				}
			)
		}
	}
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		
		if !savingMe {
			exit()
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.view.endEditing(false)
	}
	
	@IBAction func signOutButtonPressed(sender: AnyObject) {
		
		firebaseHelper.signOut()
	}
	
	@IBAction func deleteAccountButtonPressed(sender: AnyObject) {
		performSegueWithIdentifier("deleteAccountSegue", sender: self)
		
	}
	
	func exit() {
		if self.navigationController == nil {
			performSegueWithIdentifier("exitToWelcomeSegue", sender: self)
		}
		else {
			performSegueWithIdentifier("exitToSettingsSegue", sender: self)
		}
	}
	
	func returnToWelcome() {
		firebaseHelper.signOut()
		if viewIfLoaded != nil {
			performSegueWithIdentifier("exitToWelcomeSegue", sender: self)
		}
	}
	
	@IBAction func exitToProfile(segue:UIStoryboardSegue) {
		
	}
}

