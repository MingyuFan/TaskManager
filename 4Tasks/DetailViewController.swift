//
//  DetailViewController.swift
//  4Tasks
//
//  Created by MingyuFan on 4/1/17.
//  Copyright © 2017 MingyuFan. All rights reserved.
//

import UIKit
import EventKit
import CoreLocation

class DetailViewController: UIViewController, UITextFieldDelegate,UITextViewDelegate, CLLocationManagerDelegate {
    var taskStore: TaskStore!
    var eventStore: EKEventStore!
    var task: Task!
    var originalPriority: Priority!  //the task's original priority
    var priority: Priority!   //may be changed by user
    var itemName: String!
    var itemDetail: String?
    var reminder: EKReminder?
    var locationReminder: EKReminder?
    var locationManager: CLLocationManager!
    //@IBOutlet weak var reminderViewConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingLeft: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingRight: NSLayoutConstraint!
    //Time reminder view
    @IBOutlet weak var reminderBackButton: UIButton!
    @IBOutlet weak var reminderDeleteButton: UIButton!
    @IBOutlet weak var mySetReminderButton: UIButton!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    //stack main
    @IBOutlet var TaskName: UITextField!
    @IBOutlet var Detail: UITextView!
    @IBOutlet var PriorityButton: UIButton!
    @IBOutlet var DateButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var locationReminderButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Task"
        originalPriority = task.priority
        priority = task.priority
        itemName = task.name
        if let de = task.detail {
            itemDetail = de}
        
        let toolbar = UIToolbar()
        toolbar.bounds = CGRect(x: 0, y: 0, width: 320, height: 50)
        toolbar.sizeToFit()
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(handleDone(sender:)))
        ]
        
        self.Detail.inputAccessoryView = toolbar
        
        if let iden = task.reminderIdentifier {
            print("Hello!")
            print(iden)
            if let re = eventStore.calendarItem(withIdentifier: iden) as? EKReminder{
                reminder = re
                let text = DateFormatter.localizedString(from: (reminder?.alarms?[0].absoluteDate)!, dateStyle: .medium, timeStyle: .short)
                reminderButton.setTitle("Remind me at time: \(text)", for: .normal)
            }
            //reminder = eventStore.calendarItem(withIdentifier: iden) as? EKReminder
            
        } else {
            reminderButton.setTitle("No Time Reminder, Click to Add One", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TaskName.text = task.name
        if let detail = task.detail {
            Detail.text = detail
        }
        switch task.priority! {
        case Priority.UI: PriorityButton.setTitle("Priority: Urgent and Important", for: .normal)
        case Priority.NUI: PriorityButton.setTitle("Priority: Not Urgent but Important", for: .normal)
        case Priority.NUNI: PriorityButton.setTitle("Priority: Not Urgent Not Important", for: .normal)
        case Priority.UNI: PriorityButton.setTitle("Priority: Urgent but Not Important", for: .normal)
        }
        DateButton.setTitle("Created Date: \(dateFormatter.string(from: task.dateCreated))", for: .normal)
        
        //reminderViewConstraints.constant = 360
        viewLeadingLeft.constant = 400
        viewTrailingRight.constant = -400
        
        if task.locationReminderIdentifier != nil {
            locationReminderButton.setTitle("Location reminder setted", for: .normal)
        } else {
            locationReminderButton.setTitle("No location reminder", for: .normal)
        }
    }
    
    @IBAction func changeName(_ sender: UITextField) {
        if let name = sender.text {
            itemName = name
        }
    }

    @IBAction func changePriorityActionSheet(_ sender: UIButton) {
        let title = "Change Priority?"
        let message = "Set Priority to:"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let setToUI = UIAlertAction(title: "Urgent and Important", style: .destructive, handler: {
            (action)->Void in
            self.priority = Priority.UI
        })
        ac.addAction(setToUI)
        
        let setToNUI = UIAlertAction(title: "Not Urgent but Important", style: .destructive, handler: {
            (action)->Void in
            self.priority = Priority.NUI
        })
        ac.addAction(setToNUI)
        
        let setToUNI = UIAlertAction(title: "Urgent but Not Important", style: .destructive, handler: {
            (action)->Void in
            self.priority = Priority.UNI
        })
        ac.addAction(setToUNI)
        
        let setToNUNI = UIAlertAction(title: "Not Urgent Not Important", style: .destructive, handler: {
            (action)->Void in
            self.priority = Priority.NUNI
        })
        ac.addAction(setToNUNI)
        present(ac, animated: true,completion: nil)
    }
    
    @IBAction func saveTask(_ sender: UIButton) {
        task.name = itemName
        if let lastDetail = Detail.text {
            task.detail = lastDetail
        }
        if let re = reminder {
            task.reminderIdentifier = re.calendarItemIdentifier
            re.title = task.name
            re.notes = task.name
            print("set title")
        } else {
            task.reminderIdentifier = nil
        }
        if let locaRe = locationReminder {
            task.locationReminderIdentifier = locaRe.calendarItemIdentifier
        }

        if originalPriority != priority {
            taskStore.removeTask(task)
            task.priority = priority
            taskStore.insertTask(task)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    //This task is done and can be deleted
    @IBAction func taskIsDone(_ sender: UIButton) {
        let title = "Task is Done"
        let message = "Are you sure to remove this task"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            //self.taskStore.removeTask(self.task)
            self.getWorkDone()
        })
        ac.addAction(deleteAction)
        present(ac, animated: true, completion: nil)
    }
    func getWorkDone() {
        taskStore.removeTask(task)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handleDone(sender: UIButton) {
        self.Detail.resignFirstResponder()
    }
    
    @IBAction func showReminderView(_ sender: UIButton) {
        
        if let re = reminder {
            myDatePicker.date = (re.alarms?[0].absoluteDate!)!
            mySetReminderButton.setTitle("Reset", for: .normal)
        } else {
            mySetReminderButton.setTitle("Set", for: .normal)
        }
        viewLeadingLeft.constant = 0
        viewTrailingRight.constant = 0

        //reminderViewConstraints.constant = 0
    }
    
    @IBAction func leaveReminderView(_ sender: UIButton) {
        viewLeadingLeft.constant = 400
        viewTrailingRight.constant = -400
        //reminderViewConstraints.constant = 360
    }
    @IBAction func deleteReminderAndLeave(_ sender: UIButton) {
        reminderButton.setTitle("Click To Set Time Reminder", for: .normal)
        do {
            try eventStore.remove(reminder!, commit: true)
        } catch {
            print("Failed to remove reminder")
        }
        reminder = nil
        viewLeadingLeft.constant = 400
        viewTrailingRight.constant = -400
        //reminderViewConstraints.constant = 360
    }
    @IBAction func setOrResetReminder(_ sender: UIButton) {
        if reminder == nil {
            reminder = EKReminder(eventStore: eventStore)
            reminder?.calendar = eventStore.defaultCalendarForNewReminders()
        }
        
        let date = myDatePicker.date
        let alarm = EKAlarm(absoluteDate: date)
        if (reminder?.hasAlarms)! {
            reminder?.removeAlarm((reminder?.alarms?[0])!)
        }
        reminder?.addAlarm(alarm)
        do {
            try eventStore.save(reminder!,commit: true)
        } catch let error {
            print("Reminder failed with error \(error.localizedDescription)")
        }
        let text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        reminderButton.setTitle("Remind me at time: \(text)", for: .normal)
        print("Reminder set")
        
        viewLeadingLeft.constant = 400
        viewTrailingRight.constant = -400
        //reminderViewConstraints.constant = 360
    }
    //location reminder
    @IBAction func addLocationReminder(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        remindLeavingCurrentLocation()
        locationReminderButton.setTitle("Remind me when leaving current location", for: .normal)
    }
    //create location reminder
    func remindLeavingCurrentLocation() {
        locationReminder = EKReminder(eventStore: eventStore)
        locationReminder?.calendar = eventStore.defaultCalendarForNewReminders()
        locationReminder?.title = task.name
        locationReminder?.notes = "You are leaving current location"
        print("location Protocal works?")
        let location = EKStructuredLocation(title: "Current Location")
        location.geoLocation = locationManager.location
        let alarm = EKAlarm()
        
        alarm.structuredLocation = location
        alarm.proximity = EKAlarmProximity.leave
        
        locationReminder?.addAlarm(alarm)
        
        do {
            try eventStore.save(locationReminder!,commit: true)
            print("Location Reminder saved!!!!")
        } catch let error {
            print("Location reminder failed with error \(error.localizedDescription)")
        }
    }
}
