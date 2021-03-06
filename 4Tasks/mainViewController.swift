//
//  mainViewController.swift
//  4Tasks
//
//  Created by MingyuFan on 3/29/17.
//  Copyright © 2017 MingyuFan. All rights reserved.
//
//  3/29/2017 redesign structure, use container view
//  4/1/2017  main structure done, data transmission done
//  4/2/2017  AddTaskViewController.swift's funcionality done
//  4/6/2017  DetailViewController.swift done
//  4/8/2017  Cells done
//  4/13/2017 Set style for Priority; Slider menu
//  4/15/2017 Settings in slider menu: control section header
//  4/20/2017 Add reminder

import UIKit
import EventKit
import CoreLocation

class mainViewController: UIViewController, CLLocationManagerDelegate {
    var listViewController: ListViewController!
    var gridViewController: GridViewController!
    var taskStore: TaskStore!
    var locationManager: CLLocationManager!
    
    var eventStore: EKEventStore!
    
    @IBOutlet var headerListSwitch: UISwitch!
    @IBOutlet var headerGridSwitch: UISwitch!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    var menuShowing: Bool = false
    
    @IBOutlet var menuView: UIView!
    
    var containerViewController: UITabBarController!
    var addNewTaskViewController: AddTaskViewController!
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //slider menu
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {(granted, error) in
            if !granted {
                print("Access to store not granted")
            }
        })
        //configure location
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = (self as CLLocationManagerDelegate)
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //switch setting
        let defaults = UserDefaults.standard
        
        if(defaults.object(forKey: "listSwitch") != nil) {
            headerListSwitch.isOn = defaults.bool(forKey: "listSwitch")
        } else {
            headerListSwitch.isOn = true
            defaults.set(true, forKey: "ListSwitch")
        }
        
        if(defaults.object(forKey: "gridSwitch") != nil) {
            headerGridSwitch.isOn = defaults.bool(forKey: "gridSwitch")
        } else {
            headerGridSwitch.isOn = true
            defaults.set(true, forKey: "gridSwitch")
        }
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
    }
    let containerSegueName = "containerSegue"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == containerSegueName{
            containerViewController = segue.destination as! UITabBarController
            //pass taskStore to two sub viewControllers
            listViewController = containerViewController!.viewControllers?[0] as! ListViewController
            gridViewController = containerViewController!.viewControllers?[1] as! GridViewController
            listViewController.taskStore = taskStore
            listViewController.eventStore = eventStore
            listViewController.locationManager = locationManager
            gridViewController.taskStore = taskStore
            gridViewController.eventStore = eventStore
            gridViewController.locationManager = locationManager
        }
        if segue.identifier == "SegueForAddTask" {
            addNewTaskViewController = segue.destination as! AddTaskViewController
            addNewTaskViewController.taskStore = taskStore
            addNewTaskViewController.eventStore = eventStore
            addNewTaskViewController.locationManager = locationManager
        }
    }
    
    @IBAction func changeHeaderListSwitch(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if headerListSwitch.isOn {
            defaults.set(true, forKey: "listSwitch")
        } else {
            defaults.set(false, forKey: "listSwitch")
        }
    }
    @IBAction func changeHeaderGridSwitch(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if headerGridSwitch.isOn {
            defaults.set(true, forKey: "gridSwitch")
        } else {
            defaults.set(false, forKey: "gridSwitch")
        }
    }

    @IBAction func openMenu(_ sender: Any) {
        if (menuShowing) {
            leadingConstraint.constant = -210
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        } else {
            leadingConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuShowing = !menuShowing
        listViewController.tableView.reloadData()
        if(gridViewController.gridZero != nil) {
            gridViewController.gridZero.tableView.reloadData()}
        if(gridViewController.gridOne != nil) {
            gridViewController.gridOne.tableView.reloadData()}
        if(gridViewController.gridTwo != nil) {
            gridViewController.gridTwo.tableView.reloadData()}
        if(gridViewController.gridThree != nil){
            gridViewController.gridThree.tableView.reloadData()}
        
        
    }
    
}
