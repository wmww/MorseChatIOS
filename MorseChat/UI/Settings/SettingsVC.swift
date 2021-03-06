//
//  SettingsVC.swift
//  MorseChat
//
//  Created by William Wold on 7/21/16.
//  Copyright © 2016 Widap. All rights reserved.
//


import UIKit

class SettingsVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.reloadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	@IBAction func exitToSettings(segue:UIStoryboardSegue) {
		
	}
}


extension SettingsVC: UITableViewDataSource {
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Your Profile"
		}
		else {
			return "Unnamed section"
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			return 1
		}
		else {
			return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
		
		var cell: UITableViewCell
		
		switch indexPath.row {
		case 0:
			cell = tableView.dequeueReusableCellWithIdentifier("myProfileSettingsCell")!
			(cell as! MyProfileSettingsCell).setup()
		default:
			cell = tableView.dequeueReusableCellWithIdentifier("myProfileSettingsCell")!
		}
		
		return cell
	}
}

class MyProfileSettingsCell : UITableViewCell {
	
	@IBOutlet weak var displayNameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	
	func setup() {
		
		displayNameLabel.text = me.displayName
		usernameLabel.text = me.username
	}
}
