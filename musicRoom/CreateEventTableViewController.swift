//
//  CreateEventTableViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import MapKit

class CreateEventTableViewController: UITableViewController, MKMapViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    
    @IBOutlet weak var specifyTimeSwitch: UISwitch!
    @IBOutlet weak var startingTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endingTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var specifyLocationSwitch: UISwitch!
    @IBOutlet weak var radiusTextField: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var locationMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingTimeDatePicker.minimumDate = Date()
        
        var components = DateComponents()
        components.setValue(1, for: .hour)
        endingTimeDatePicker.minimumDate = Calendar.current.date(byAdding: components, to: Date())
    }
    
    @IBAction func specifyTimeChanged(_ sender: UISwitch) {
        if sender.isOn {
            startingTimeDatePicker.isEnabled = false
            endingTimeDatePicker.isEnabled = false
        } else {
            startingTimeDatePicker.isEnabled = true
            endingTimeDatePicker.isEnabled = true
        }
    }
    
    @IBAction func specifyLocationChanged(_ sender: UISwitch) {
        if sender.isOn {
            radiusTextField.text = "hello"
            radiusSlider.isEnabled = false
        } else {
            startingTimeDatePicker.isEnabled = true
            endingTimeDatePicker.isEnabled = true
        }
    }
    
    
    
    
    
//    @IBOutlet weak var name: UITextField!
//    @IBOutlet weak var visibility: UISegmentedControl!
//    @IBOutlet weak var startDate: UIDatePicker!
//    @IBOutlet weak var endDate: UIDatePicker!
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var rightLabel: UILabel!
//    @IBOutlet weak var betweenLabel: UILabel!
//    @IBOutlet weak var andLabel: UILabel!
//    @IBOutlet weak var located: UISwitch!
    
    @IBAction func locatedChange(_ sender: UISwitch) {
        if sender.isOn { // If located
            betweenLabel.isHidden = false
            andLabel.isHidden = false
            startDate.isHidden = false
            endDate.isHidden = false
            mapView.isHidden = false
        } else {
            betweenLabel.isHidden = true
            andLabel.isHidden = true
            startDate.isHidden = true
            endDate.isHidden = true
            mapView.isHidden = true
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.centerCoordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    
    
    
    @IBAction func finish(_ sender: UIBarButtonItem) {
        guard self.name.text != "" else {
            self.showBasicAlert(title: "No Title", message: "Please give a name to your event.")
            return
        }
        
        
        
        if located.isOn && startDate.date >= endDate.date {
            self.showBasicAlert(title: "Date contradiction", message: "The end date must be after the start date.")
            return
        }
        
        if let currentUser = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference(withPath: "users/" + currentUser)
            
            var eventRef : DatabaseReference
            // if public
            if self.visibility.selectedSegmentIndex == 0 {
                eventRef = Database.database().reference(withPath: "events/public")
            } else {
                eventRef = Database.database().reference(withPath: "events/private")
            }
            
            let newEventRef = eventRef.childByAutoId()
            var event = Event(name: self.name.text!, userId: (Auth.auth().currentUser?.uid)!)
            
            if located.isOn {
                event.startDate = startDate.date.toString()
                event.endDate = endDate.date.toString()
                event.longitude = mapView.centerCoordinate.longitude
                event.latitude = mapView.centerCoordinate.latitude
            }
            if visibility.selectedSegmentIndex == 1 || rights.selectedSegmentIndex == 1 {
                event.userIds = [(Auth.auth().currentUser?.uid)!: true]
            }
            
            newEventRef.setValue(event.toDict())
            if self.visibility.selectedSegmentIndex == 1 {
                userRef.child("events/" + newEventRef.key).setValue(self.name.text)
            }
            
            self.performSegue(withIdentifier: "unwindToEvents", sender: self)
            
        }
    }
}
