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
    
    @IBAction func visibilityChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            rightLabel.isHidden = false
            rightLabel.text = "Voting rights"
            rights.isHidden = false
            betweenLabel.isHidden = true
            andLabel.isHidden = true
            startDate.isHidden = true
            endDate.isHidden = true
            mapView.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            rightLabel.text = "Only invited users can see your private events"
            rights.isHidden = true
            betweenLabel.isHidden = true
            andLabel.isHidden = true
            startDate.isHidden = true
            endDate.isHidden = true
            mapView.isHidden = true
        }
    }
    
    @IBAction func rightsChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
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
        scrollView.contentSize.height = 600
        
        betweenLabel.isHidden = true
        andLabel.isHidden = true
        startDate.isHidden = true
        endDate.isHidden = true
        mapView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    // TODO: If private hide everything else
    // TODO: If not located hide date and map
    @IBAction func finish(_ sender: UIButton) {
        if self.name.text == "" {
            print("Empty name")
            return
        } else if rights.selectedSegmentIndex == 2 {
            if startDate.date >= endDate.date {
                print("startDate >= endDate")
                return
            }
        } else if visibility.selectedSegmentIndex == 1 && rights.selectedSegmentIndex == 2 {
            print("Event can not be private and located at the same time")
            return
        } else if visibility.selectedSegmentIndex == 1 && rights.selectedSegmentIndex == 0 {
            print("Event can not be private and accept voting of everybody")
            return
        }
        
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            let userRef = FIRDatabase.database().reference(withPath: "users/" + currentUser)
            
            var eventRef : FIRDatabaseReference
            // if public
            if self.visibility.selectedSegmentIndex == 0 {
                eventRef = FIRDatabase.database().reference(withPath: "events/public")
            } else {
                eventRef = FIRDatabase.database().reference(withPath: "events/private")
            }
            
            let newEventRef = eventRef.childByAutoId()
            var event = Event(name: self.name.text!, userId: (FIRAuth.auth()?.currentUser?.uid)!)
            
            if rights.selectedSegmentIndex == 2 {
                event.startDate = startDate.date.toString()
                event.endDate = endDate.date.toString()
                event.longitude = mapView.centerCoordinate.longitude
                event.latitude = mapView.centerCoordinate.latitude
            }
            
            // public
            if self.visibility.selectedSegmentIndex == 0 {
                newEventRef.setValue(event.toPublicObject())
            }
            // public, only invited can vote
            if self.visibility.selectedSegmentIndex == 0 && self.rights.selectedSegmentIndex == 1 {
                newEventRef.setValue(event.toPublicInvitedObject())
            }
            // public located
            if self.visibility.selectedSegmentIndex == 0 && self.rights.selectedSegmentIndex == 2 {
                newEventRef.setValue(event.toPublicLocationObject())
            }
            // private
            if self.visibility.selectedSegmentIndex == 1 {
                newEventRef.setValue(event.toPrivateObject())
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
