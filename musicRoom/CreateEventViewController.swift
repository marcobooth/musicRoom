//
//  CreateEventViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import MapKit

extension Date
{
    func toString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)!
    }
}

class CreateEventViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var visibility: UISegmentedControl!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rights: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var betweenLabel: UILabel!
    @IBOutlet weak var andLabel: UILabel!
    @IBOutlet weak var located: UISwitch!
    
    @IBAction func visibilityChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // If public
            rightLabel.isHidden = false
            rightLabel.text = "Voting rights"
            rights.isHidden = false
        } else if sender.selectedSegmentIndex == 1 { // if Private
            rightLabel.text = "Only invited users can see your private events"
            rights.isHidden = true
        }
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate.minimumDate = Date()
        endDate.minimumDate = Date()
        self.mapView.delegate = self
        //scrollView.contentSize.height = 600
    }
    
    @IBAction func finish(_ sender: UIBarButtonItem) {
        if self.name.text == "" {
            self.showBasicAlert(title: "No Title", message: "Please give a name to your event.")
            return
        } else if located.isOn && startDate.date >= endDate.date {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
