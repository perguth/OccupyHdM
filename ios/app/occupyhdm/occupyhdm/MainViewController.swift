//
//  MainViewController.swift
//  occupyhdm
//
//  Created by Fabian Kugler on 22.03.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var accuracyWarning: UIView!
    @IBOutlet weak var accuracyOverlay: UIView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(48.742393, 9.101142), MKCoordinateSpanMake(0.005, 0.005)), animated: false)
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        self.disableUserAnnotationView(self.mapView.userLocation)
        
        let jsonString = "{ \"locations\" : [ { \"name\" : \"Location 1\", \"lat\" : 48.742070, \"lon\" : 9.102263 }, { \"name\" : \"Location 2\", \"lat\" : 48.740995, \"lon\" : 9.101709 } ] }"
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            if let locations = jsonDictionary["locations"] as? NSArray
            {
                for location in locations
                {
                    self.mapView.addAnnotation(CustomAnnotation(
                        coordinate: CLLocationCoordinate2DMake(
                            (location["lat"] as! NSNumber).doubleValue,
                            (location["lon"] as! NSNumber).doubleValue),
                        title: location["name"] as! String)
                    )
                }
            }
        }
        catch {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logout(sender: AnyObject) {
        
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // changing picture of map annotations
        
        if annotation.isEqual(self.mapView.userLocation)
        {
            return nil
        }
        
        var aView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView")
        
        if aView == nil
        {
            aView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
        }
        
        aView!.canShowCallout = true
        
        let currentAnnotation = aView!.annotation as! CustomAnnotation
        
        if currentAnnotation.state
        {
            aView!.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_green", ofType: "png")!)
        }
        else
        {
            aView!.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_red", ofType: "png")!)
        }

        return aView
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.disableUserAnnotationView(userLocation)
        
        let accuracy = userLocation.location!.horizontalAccuracy
        
        let savedAccuracy = NSUserDefaults.standardUserDefaults().integerForKey("accuracy")
        
        if accuracy >= Double(savedAccuracy)
        {
            self.accuracyWarning.hidden = false
            self.accuracyOverlay.hidden = false
        }
        else
        {
            self.accuracyWarning.hidden = true
            self.accuracyOverlay.hidden = true
            
            for annotation in self.mapView.annotations
            {
                if annotation.isEqual(userLocation)
                {
                    continue
                }
                
                let customAnnotation = annotation as! CustomAnnotation
                
                let pinLocation = CLLocation(latitude: customAnnotation.coordinate.latitude, longitude: customAnnotation.coordinate.longitude)
                let userLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
                let distance = pinLocation.distanceFromLocation(userLocation)
                
                let savedDistance = NSUserDefaults.standardUserDefaults().integerForKey("distance")
                
                if distance <= Double(savedDistance)
                {
                    customAnnotation.toggleState(true)
                    self.mapView.viewForAnnotation(customAnnotation)!.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_green", ofType: "png")!)
                }
                else
                {
                    customAnnotation.toggleState(false)
                    self.mapView.viewForAnnotation(customAnnotation)!.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_red", ofType: "png")!)
                }
                
                NSLog("distance: " + String(pinLocation.distanceFromLocation(userLocation)))
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            self.mapView.showsUserLocation = true
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: - custom methods
    func disableUserAnnotationView(userLocation: MKUserLocation)
    {
        if let userAnnotationView = self.mapView.viewForAnnotation(userLocation)
        {
            userAnnotationView.enabled = false
        }
    }
}
