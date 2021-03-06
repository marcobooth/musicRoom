//
//  CreateEventTableViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import MapKit

class CreateEventTableViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    
    @IBOutlet weak var specifyTimeSwitch: UISwitch!
    @IBOutlet weak var startingTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endingTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var specifyLocationSwitch: UISwitch!
    @IBOutlet weak var radiusTextField: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var locationMarkerImage: UIImageView!
    @IBOutlet weak var anywhereMapLabel: UILabel!
    @IBOutlet weak var followUserButton: UIButton!
    var locationFollowsUser = true
    
    let locationManager = CLLocationManager()
    
    // 10 meters to 10 km, default value of 200
    var radiusMeters: Int?
    let radiusMinimum = Float(20)
    let radiusMaximum = Float(10000)
    let sliderToRadiusPow = Float(8.0)
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        startingTimeDatePicker.minimumDate = Date()
        
        var components = DateComponents()
        components.setValue(1, for: .hour)
        endingTimeDatePicker.minimumDate = Calendar.current.date(byAdding: components, to: Date())
        
        radiusSlider.minimumValue = 1
        radiusSlider.maximumValue = pow(radiusMaximum / radiusMinimum, Float(1.0 / sliderToRadiusPow))
        radiusSlider.value = pow(100 / radiusMinimum, Float(1.0 / sliderToRadiusPow))
        setRadius()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            locationMapView.showsUserLocation = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    @IBAction func specifyTimeChanged(_ sender: UISwitch) {
        if sender.isOn {
            startingTimeDatePicker.isEnabled = true
            endingTimeDatePicker.isEnabled = true
        } else {
            startingTimeDatePicker.isEnabled = false
            endingTimeDatePicker.isEnabled = false
        }
    }
    
    @IBAction func specifyLocationChanged(_ sender: UISwitch) {
        if sender.isOn {
            setRadius()
            self.radiusSlider.isEnabled = true
            
            self.locationMapView.isZoomEnabled = true
            self.locationMapView.isScrollEnabled = true
            self.locationMapView.isUserInteractionEnabled = true
            
            self.locationMarkerImage.isHidden = false
            self.anywhereMapLabel.isHidden = true
            self.locationMapView.showsUserLocation = true
        } else {
            self.locationMapView.removeOverlays(self.locationMapView.overlays)
            self.radiusTextField.text = "Infinite"
            self.radiusSlider.isEnabled = false
            
            self.locationMapView.isZoomEnabled = false
            self.locationMapView.isScrollEnabled = false
            self.locationMapView.isUserInteractionEnabled = false
            
            self.locationMarkerImage.isHidden = true
            self.anywhereMapLabel.isHidden = false
            self.locationMapView.showsUserLocation = false
        }
    }
    
    @IBAction func refollowUser(_ sender: UIButton) {
        self.locationMapView.centerCoordinate = self.locationMapView.userLocation.coordinate
        self.locationFollowsUser = true
        self.followUserButton.isHidden = true
    }
    
    @IBAction func radiusSliderChanged(_ sender: UISlider) {
        setRadius()
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem) {
        guard let eventName = self.nameTextField.text, eventName != "" else {
            self.showBasicAlert(title: "No Title", message: "Please give a name to your event.")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Unclear how they even got to the create event page without being logged in...")
            return
        }
        
        var newEvent = Event(name: eventName, createdBy: userId)
        
        if !publicOrPrivateSwitch.isOn {
            newEvent.userIds = [userId: true]
        }
        
        if specifyTimeSwitch.isOn {
            guard startingTimeDatePicker.date < endingTimeDatePicker.date else {
                self.showBasicAlert(title: "Whatcha tryin' to do?", message: "The end date must be after the start date.")
                return
            }
            
            newEvent.startDate = UInt(self.startingTimeDatePicker.date.timeIntervalSince1970)
            newEvent.endDate = UInt(self.endingTimeDatePicker.date.timeIntervalSince1970)
        }
        
        if specifyLocationSwitch.isOn {
            guard let radius = self.radiusMeters else {
                print("Unclear how we couldn't parse the int...")
                return
            }
            
            newEvent.radius = radius
            newEvent.latitude = self.locationMapView.centerCoordinate.latitude
            newEvent.longitude = self.locationMapView.centerCoordinate.longitude
        }
        
        let eventsPath = "events/" + (publicOrPrivateSwitch.isOn ? "public" : "private")
        let eventRef = Database.database().reference(withPath: eventsPath)
        let newEventRef = eventRef.childByAutoId()
        
        if self.publicOrPrivateSwitch.isOn {
            newEventRef.setValue(newEvent.toDict()) { error, _ in
                guard error == nil else { return }
                
                Analytics.logEvent("created_event", parameters: Log.defaultInfo())
            }
        } else {
            let newPrivateEventRef : [String:Any] = ["users/\(userId)/events/\(newEventRef.key)": eventName, "events/private/\(newEventRef.key)": newEvent.toDict()]
            let ref = Database.database().reference()
            ref.updateChildValues(newPrivateEventRef, withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error updating data: \(error.debugDescription)")
                    self.showBasicAlert(title: "Error", message: "This probably means that Firebase denied access")
                }
                Analytics.logEvent("created_event", parameters: Log.defaultInfo())
            })
        }

        self.performSegue(withIdentifier: "unwindToEvents", sender: self)
    }
    
    // MARK: helpers
    
    private func setRadius() {
        let meters = pow(radiusSlider.value, sliderToRadiusPow) * radiusMinimum
        var metersString = String(format:"%.0f", meters)
        
        if metersString.characters.count > 2 {
            let firstTwo = metersString.substring(to: metersString.index(metersString.startIndex, offsetBy: 2))
            
            metersString = firstTwo + String(repeating: "0", count: metersString.characters.count - 2)
        }
        
        self.radiusMeters = Int(metersString)
        
        if let parsedInt = self.radiusMeters  {
            if parsedInt >= 1000 {
                self.radiusTextField.text = String(format: "%.1f", Float(parsedInt) / 1000) + " km"
            } else {
                self.radiusTextField.text = "\(parsedInt) meters"
            }
            setCircle()
        } else {
            self.radiusTextField.text = "Error"
        }

    }
    
    private func setCircle() {
        self.locationMapView.removeOverlays(self.locationMapView.overlays)
        if let radius = radiusMeters {
            self.locationMapView.add(MKCircle(center: self.locationMapView.centerCoordinate, radius: CLLocationDistance(radius)))
        }
    }
    
    // MARK: location-related stuff
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Check if it was the user that is moving the map: https://stackoverflow.com/a/30924768

        if let gestureRecognizers = self.locationMapView.subviews[0].gestureRecognizers {
            for recognizer in gestureRecognizers {
                if (recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    self.locationFollowsUser = false
                    self.followUserButton.isHidden = false
                    
                    return
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setCircle()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if specifyLocationSwitch.isOn, self.locationFollowsUser, let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.locationMapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            circleRenderer.strokeColor = UIColor.blue
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
}
