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
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

class CreateEventViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var visibility: UISegmentedControl!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var rights: UISegmentedControl!
    
    
    // TODO: If private hide everything else
    // TODO: If not located hide date and map
    @IBAction func finish(_ sender: UIButton) {
        if self.name.text == "" {
            print("Empty name")
            return
        } else if rights.selectedSegmentIndex == 2 {
            if startDate.date > endDate.date {
                print("startDate > endDate")
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
                event.startDate = startDate.date.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
                event.endDate = startDate.date.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
               // event.location = map.userLocation ???????????
            }
            
            // public
            if self.visibility.selectedSegmentIndex == 0 {
                newEventRef.setValue(event.toPublicObject())
            }
            // public, onnly invited can vote
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate.minimumDate = Date();
        endDate.minimumDate = Date();

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
