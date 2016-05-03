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
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    
    var locationManager = CLLocationManager()
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        self.labelUsername.text = NSUserDefaults.standardUserDefaults().stringForKey("username")
        self.labelScore.text = String(NSUserDefaults.standardUserDefaults().integerForKey("score"))
        
        self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(48.742393, 9.101142), MKCoordinateSpanMake(0.005, 0.005)), animated: false)
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        self.disableUserAnnotationView(self.mapView.userLocation)        
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        }
        
        let refreshRate = NSUserDefaults.standardUserDefaults().integerForKey("refreshRate")
        
        self.update()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(refreshRate), target: self, selector: #selector(MainViewController.update), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.timer!.invalidate()
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
        
        self.setAnnotationImage(currentAnnotation)

        return aView
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.disableUserAnnotationView(userLocation)
        
        func creditPoints() {
            var score = NSUserDefaults.standardUserDefaults().integerForKey("score")
            score += 50
            self.labelScore.text = String(score)
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "score")
        }
        func checkProximity(customAnnotation: CustomAnnotation) {
            let pinLocation = CLLocation(latitude: customAnnotation.coordinate.latitude, longitude: customAnnotation.coordinate.longitude)
            let userLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let distance = pinLocation.distanceFromLocation(userLocation)
            let savedDistance = NSUserDefaults.standardUserDefaults().integerForKey("distance")
            
            if distance <= Double(savedDistance)
            {
                let username = NSUserDefaults.standardUserDefaults().stringForKey("username")
                let queryString = "/own/" + customAnnotation.name! + "/" + username!
                RestApiManager.sharedInstance.makeRestRequest(queryString) {
                    (result: AnyObject) in
                }
                
                self.setAnnotationImage(customAnnotation)
                creditPoints()
            }
        }
        
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
                if annotation.isEqual(userLocation) { continue }
                
                checkProximity(annotation as! CustomAnnotation)
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
    
    func update()
    {
        func updateOrSetLocationAnnotation(location: AnyObject) {
            let name = location["name"] as! String
            let customAnnotations = NSMutableArray(array: self.mapView.annotations)
            var found = false
            
            customAnnotations.removeObject(self.mapView.userLocation)
            
            for annotation in customAnnotations as NSArray as! [CustomAnnotation]
            {
                if name == annotation.name!
                {
                    found = true
                    
                    annotation.coordinate = CLLocationCoordinate2DMake(
                        (location["lat"] as! NSNumber).doubleValue,
                        (location["lon"] as! NSNumber).doubleValue)
                    annotation.owner = location["owner"] as? String
                    annotation.title = name + " - Owner: " + annotation.owner!
                    
                    dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                        self.setAnnotationImage(annotation)
                    })
                }
            }
            
            if !found
            {
                let annotation = CustomAnnotation(
                    coordinate: CLLocationCoordinate2DMake(
                        (location["lat"] as! NSNumber).doubleValue,
                        (location["lon"] as! NSNumber).doubleValue),
                    name: location["name"] as! String,
                    owner: location["owner"] as! String)
                
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.mapView.addAnnotation(annotation)
                })
            }
        }
        
        RestApiManager.sharedInstance.makeRestRequest("/goals") { (result: AnyObject) in
                // needs to run on the main thread or else it won't render
                
                if let locations = result["locations"] as? NSArray
                {
                    for location in locations
                    {
                        updateOrSetLocationAnnotation(location)
                    }
                }
        }
    }
    
    func setAnnotationImage(annotation: CustomAnnotation)
    {
        let username = NSUserDefaults.standardUserDefaults().stringForKey("username")
        
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            if let annotationView = self.mapView.viewForAnnotation(annotation)
            {
                if annotation.owner == username
                {
                    annotationView.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_green", ofType: "png")!)
                }
                else
                {
                    annotationView.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_red", ofType: "png")!)
                }
            }
        })
    }
}
