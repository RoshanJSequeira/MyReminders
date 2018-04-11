//
//  ReminderListViewController.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderListViewController: UIViewController {

    
    @IBOutlet weak var addAReminderLabel: UILabel!
    @IBOutlet weak var remindersTableView: UITableView!

    var reminderList = [Reminders]()
    

    func getAllReminders()
    {
        reminderList.removeAll()
        reminderList = CoreDataHandler.fetchReminders()!
        
        if reminderList.count > 0
        {
            addAReminderLabel.isHidden = true
            self.remindersTableView.isHidden = false
            self.remindersTableView.reloadData()
        }
        else
        {
            addAReminderLabel.isHidden = false
            self.remindersTableView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllReminders()
        
    }
    

    @IBAction func addButtonAction(_ sender: UIButton)
    {
        let createRemindersViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateRemindersViewController") as! CreateRemindersViewController
        self.present(createRemindersViewController, animated: true)
    }
}

extension ReminderListViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.reminderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.ReminderTableViewCell) as! ReminderTableViewCell
        let reminder = self.reminderList[indexPath.row]
        cell.reminder = reminder
        return cell
    }
}


extension ReminderListViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let reminder = self.reminderList[indexPath.row]
        let createRemindersViewController = self.storyboard?.instantiateViewController(withIdentifier: ControllerIdentifier.CreateRemindersViewController) as! CreateRemindersViewController
        createRemindersViewController.reminder = reminder
        self.present(createRemindersViewController, animated: true)
        
    }
}

