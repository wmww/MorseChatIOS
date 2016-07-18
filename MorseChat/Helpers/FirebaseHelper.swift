//
//  FirebaseHelper.swift
//  MorseChat
//
//  Created by William Wold on 7/11/16.
//  Copyright © 2016 Widap. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseAuthUI

let firebaseHelper = FirebaseHelper()

class FirebaseHelper : NSObject {
	
	var firebaseUser: FIRUser?
	var auth: FIRAuth?
	var root: FIRDatabaseReference?
	
	override init() {
		
		super.init()
		
		//callback is used so user is not requested while internal state is changing or some BS like that
		
		FIRApp.configure()
		
		auth = FIRAuth.auth()!
		
		root = FIRDatabase.database().reference()
		
		FIRAuth.auth()?.addAuthStateDidChangeListener(
			{ auth, user in
				print("\n\n\nlogin state changed, user: \(user?.displayName)\n\n\n")
				self.firebaseUser = user
			}
		);
	}
	
	func loginUI(vc: UIViewController) {
		
		let authUI = FIRAuthUI.authUI()!
		authUI.delegate = self
		let authViewController = authUI.authViewController()
		vc.presentViewController(authViewController, animated: true, completion: nil)
	}
	
	//downloads various data including friend array and me User
	func downloadUserData(success: () -> Void, fail: () -> Void) {
		
		var error = false
		var downloadsLeft = 2;
		
		userDataDownloaded = false
		
		if (firebaseUser == nil) {fail()}
		let user = firebaseUser!
		
		func downloadDone() {
			
			downloadsLeft -= 1;
			
			if downloadsLeft==0 {
				if error {
					fail()
				}
				else {
					success()
				}
			}
			else if downloadsLeft < 0 {
				print("downloadsLeft dropped below 0")
				fail()
			}
		}
		
		self.getUserfromKey(user.uid,
			callback: { (usr) in
				if let usr = usr {
					me = usr
					downloadDone()
				}
				else {
					error = true
					downloadDone()
				}
			}
		)
		
		friends.removeAll();
		
		root!.child("friendsByUser/\(user.uid)").observeEventType(.Value,
			withBlock: { (data: FIRDataSnapshot) in
				
				var elemLeft = data.childrenCount
				
				//if there are no friends it has to be handeled differently
				if elemLeft == 0 {
					downloadDone()
				}
				
				for i in data.children {
					self.getUserfromKey(i.key,
						callback: { (userIn: User?) -> Void in
							
							if let userIn = userIn {
								friends.append(userIn.toFriend())
							}
							else {
								friends.append(Friend(nameIn: "error downloading friend", keyIn: "errorKey"))
							}
							
							elemLeft -= 1
							
							if elemLeft == 0 {
								downloadDone()
							}
						}
					)
				}
			}
		)
	}
	
	func getUserfromKey(key: String, callback: (usr: User?) -> Void) {
		
		root!.child("users/\(key)").observeEventType(.Value,
			withBlock: { (data: FIRDataSnapshot) in
				
				if (data.exists()) {
					
					let usr = User()
					
					usr.fullName = data.value!["name"] as! String
					usr.key = key
					
					callback(usr: usr)
				}
				else {
					callback(usr: nil)
				}
			}
		)
	}
	
	func signInWithEmail(email: String, password: String, successCallback: ()->Void, failCallback: ()->Void) {
		auth!.signInWithEmail(email, password: password,
			completion: { FIRAuthResultCallback in
				//sign in worked
				
				
			}
		)
	}
	
	func setLineInListner(friend: Friend, callback: (lineOn: Bool) -> Void) {
		
		root!.child("friendsByUser/\(me.key)/\(friend.key)").observeEventType(.Value,
			withBlock: { (data: FIRDataSnapshot) -> Void in
				
				let state = data.value as! Bool
				
				callback(lineOn: state)
			}
		)
	}
	
	func setLineToUserStatus(otherUserKey: String, lineOn: Bool) {
		
		root!.child("friendsByUser/\(otherUserKey)").updateChildValues([me.key : lineOn])
			///\(otherUserKey)")
		
	}
}

extension FirebaseHelper : FIRAuthUIDelegate {
	
	@objc func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
		
		//this shpuld be done by the listener I set in the init method
		//firebaseUser = user
		
		//create a new user if it doesn't already exist
		if let user = user {
			getUserfromKey(user.uid,
				callback: { (userIn: User?) -> Void in
					if let userIn = userIn {
						me = userIn
					}
					else
					{
						//create a new user here
						self.root?.child("users/\(user.uid)").updateChildValues(["name": user.displayName ?? "noName"])
					}
				}
			)
		}
		
		if let error = error {
			
			print("login error: \(error.localizedDescription)")
		}
	}
}
