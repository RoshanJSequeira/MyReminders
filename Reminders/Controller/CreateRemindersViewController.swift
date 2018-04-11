//
//  CreateRemindersViewController.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//

import UIKit
import UserNotifications

class CreateRemindersViewController: ReminderBaseViewController {

    @IBOutlet weak var reminderTime: UITextField!
    @IBOutlet weak var reminderText: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var reminderTypeLabel: UILabel!
    
    var dateTimePicker: UIDatePicker = UIDatePicker()
    var reminder:Reminders?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        dateTimePicker.datePickerMode  = .dateAndTime
        self.reminderTime.inputView = dateTimePicker
        dateTimePicker.minimumDate = Date()
        dateTimePicker.timeZone = TimeZone.current
        
        if let reminder = self.reminder
        {
            self.reminderTime.text = reminder.time!
            self.reminderText.text = reminder.text!
            self.updateButton.isHidden = false
            self.deleteButton.isHidden = false
            self.saveButton.isHidden = true
            reminderTypeLabel.text = "Update / Delete Reminder"
            
            //set the date of the picker
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormats.DisplayDateFormat
            dateFormatter.timeZone = TimeZone.current
            let date = dateFormatter.date(from: self.reminderTime.text!)
            print(date ?? "")
            self.dateTimePicker.date = date!
            
        }
        else
        {
            self.updateButton.isHidden = true
            self.deleteButton.isHidden = true
            self.saveButton.isHidden = false
             reminderTypeLabel.text = "Create Reminder"
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateRemindersViewController.updateDate) , name: NSNotification.Name(rawValue: NotificationConstants.DateSelected), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.DateSelected), object: nil)
    }

    @IBAction func closeButonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func updateReminders(_ sender: UIButton)
    {
        if (self.reminderText.text?.count == 0 || self.reminderTime.text?.count == 0)
        {
            let alert =  UIAlertController(title: "Alert", message: "Please specify the name and time of reminder", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        else
        {
            //just save the reminder by updating the nsmanageedobject model
            if let reminder = self.reminder
            {
                self.updateDate()
                
                reminder.text = self.reminderText.text!
                reminder.time = self.reminderTime.text!
                //save it
                do
                {
                    try CoreDataHandler.getContext().save()
                }
                catch(let err)
                {
                    print(err)
                }
            }
            self.dismiss(animated: true)
        }
    }
    
    
    @objc func updateDate()
    {
        let dateFromPicker = self.dateTimePicker.date
        let dateFormatter = DateFormatter()
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = DateFormats.DisplayDateFormat
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: dateFromPicker)
        self.reminderTime.text = timeStamp
        //it may be update or new. If update you need to reschdeule the alarm as well.
        if self.reminder != nil
        {
            //when a reminder is saved same identifier, previous reminder gets updated
            self.scheduleNotification(identifier: (self.reminder?.time!)!)
        }
    }
    
    
    @IBAction func deleteButtonAction(_ sender : UIButton)
    {
        if let reminder = self.reminder
        {
            let identifier = reminder.time
            //remove the old notificaiton with identifier if it was pending
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier!])
         }
        CoreDataHandler.deleteReminder(reminder: self.reminder!)
        self.dismiss(animated: true)
    }
    
    
    func scheduleNotification(identifier:String)
    {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Reminder", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: self.reminderText.text!,
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        
        let date = self.dateTimePicker.date
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
        })
    }

    @IBAction func saveButtonAction(_ sender: UIButton)
    {
        if (self.reminderText.text?.count == 0 || self.reminderTime.text?.count == 0)
        {
           let alert =  UIAlertController(title: "Alert", message: "Please specify the name and time of reminder", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        else
        {
            //update time
            self.updateDate()
            self.scheduleNotification(identifier: self.reminderTime.text!)
            CoreDataHandler.saveReminder(remiderText: self.reminderText.text!, time: self.reminderTime.text!)
            self.dismiss(animated: true)
        }
    }
}


extension UITextField
{
    @objc func doneButtonAction()
    {
        //post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.DateSelected), object: nil)
        self.resignFirstResponder()
    }
}
