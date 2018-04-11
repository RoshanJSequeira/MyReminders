//
//  CreateRemindersViewController.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//

import UIKit
import  UserNotifications

class CreateRemindersViewController: UIViewController {

    @IBOutlet weak var reminderTime: UITextField!
    @IBOutlet weak var reminderText: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var reminderTypeLabel: UILabel!
    
    var dateTimePicker: UIDatePicker = UIDatePicker()
    var reminder:Reminders?

    override func viewDidLoad() {
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
        NotificationCenter.default.addObserver(self, selector: #selector(CreateRemindersViewController.updateDate) , name: NSNotification.Name(rawValue: "DateSelected"), object: nil)
    }

    @IBAction func closeButonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func updateReminders(_ sender: UIButton)
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
    
    
    @objc func updateDate()
    {
        let dateFromPicker = self.dateTimePicker.date
        let dateFormatter = DateFormatter()
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "dd-MM-yy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: dateFromPicker)
        self.reminderTime.text = timeStamp
        //it may be update or new. If update you need to reschdeule the alarm as well.
        if self.reminder != nil
        {
            self.scheduleNotification(identifier: (self.reminder?.time!)!)
        }
    }
    
    
    @IBAction func deleteButtonAction(_ sender : UIButton)
    {
        if let reminder = self.reminder
        {
            //this is an update to existing time. So you need to update the time of reminder!
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
        //update time
        self.updateDate()
        self.scheduleNotification(identifier: self.reminderTime.text!)
        CoreDataHandler.saveReminder(remiderText: self.reminderText.text!, time: self.reminderTime.text!)
        self.dismiss(animated: true)
    }
}



extension Date {
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date? {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
            
            return self.addingTimeInterval(targetOffset - localOffeset)
        }
        
        return nil
    }
}

extension UITextField
{
    @objc func doneButtonAction()
    {
        //self.reminderTime.text = self.dateTimePicker.date.description
        //post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DateSelected"), object: nil)
        self.resignFirstResponder()
    }
}
